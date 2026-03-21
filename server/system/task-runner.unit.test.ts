import { expect } from 'bun:test'
import { createTypedStorage } from '~/system/storage'
import { createTaskRunner, type TaskDefinition, type TaskState } from '~/system/task-runner'
import { and, feature, given, scenario, then, when } from '~/test/bdd'

const createTestDefinition = (
  items: string[],
  onExecute?: (item: string) => Promise<void>,
): TaskDefinition<string> => ({
  items: async () => items,
  execute: onExecute ?? (async () => {}),
  label: (item) => `Processing "${item}"`,
})

feature('Task Runner', () => {
  scenario('starts a task, progresses through items, and completes', async () => {
    given('a task runner with 3 items')
    const runner = createTaskRunner('test-progress')
    const executed: string[] = []
    const definition = createTestDefinition(['a', 'b', 'c'], async (item) => {
      executed.push(item)
    })

    when('the task is started')
    const result = await runner.start(definition)

    then('it completes successfully')
    expect(result).toBe('completed')

    and('all items were executed')
    expect(executed).toEqual(['a', 'b', 'c'])

    and('the final state reflects completion')
    const state = await runner.getState()
    expect(state.phase).toBe('completed')
    expect(state.current).toBe(3)
    expect(state.total).toBe(3)
    expect(state.startedAt).toBeInstanceOf(Date)
    expect(state.completedAt).toBeInstanceOf(Date)
  })

  scenario('cancels during execution', async () => {
    given('a task runner with 3 items that cancels after the first')
    const runner = createTaskRunner('test-cancel')
    const executed: string[] = []
    const definition = createTestDefinition(['a', 'b', 'c'], async (item) => {
      executed.push(item)
      if (item === 'a') runner.cancel()
    })

    when('the task is started')
    const result = await runner.start(definition)

    then('it returns cancelled')
    expect(result).toBe('cancelled')

    and('only the first item was executed')
    expect(executed).toEqual(['a'])

    and('the state reflects cancellation')
    const state = await runner.getState()
    expect(state.phase).toBe('cancelled')
    expect(state.completedAt).toBeInstanceOf(Date)
  })

  scenario('pauses then resumes execution', async () => {
    given('a task runner with 3 items')
    const runner = createTaskRunner('test-pause')
    const executed: string[] = []
    const definition = createTestDefinition(['a', 'b', 'c'], async (item) => {
      executed.push(item)
      if (item === 'a') {
        runner.pause()
        // Resume after a brief delay to allow pause to take effect
        setTimeout(() => runner.resume(), 10)
      }
    })

    when('the task is started and paused after first item')
    const result = await runner.start(definition)

    then('it completes after resuming')
    expect(result).toBe('completed')

    and('all items were executed')
    expect(executed).toEqual(['a', 'b', 'c'])
  })

  scenario('rejects start when already running', async () => {
    given('a task runner with a slow-running task')
    const runner = createTaskRunner('test-already-running')
    let resolveItem = () => {}
    const blockingDefinition: TaskDefinition<string> = {
      items: async () => ['a'],
      execute: async () => {
        await new Promise<void>((resolve) => {
          resolveItem = resolve
        })
      },
      label: (item) => `Processing "${item}"`,
    }

    when('the task is started')
    const firstRun = runner.start(blockingDefinition)

    // Wait a tick for the task to actually start
    await new Promise((resolve) => setTimeout(resolve, 10))

    and('a second start is attempted')
    const secondResult = await runner.start(blockingDefinition)

    then('the second start returns already-running')
    expect(secondResult).toBe('already-running')

    // Clean up: resolve the blocking task
    resolveItem()
    await firstRun
  })

  scenario('self-heals a task interrupted mid-run', async () => {
    given('a task state stuck in running phase (simulating a crash)')
    const storage = createTypedStorage<TaskState>('task:test-selfheal')
    await storage.setItem('state', {
      phase: 'running',
      current: 2,
      total: 5,
      message: 'Interrupted',
      startedAt: new Date(),
      completedAt: null,
    })

    when('selfHeal is called on a fresh runner instance')
    const runner = createTaskRunner('test-selfheal')
    await runner.selfHeal()

    then('the state is marked as failed')
    const state = await runner.getState()
    expect(state.phase).toBe('failed')
    expect(state.completedAt).toBeInstanceOf(Date)
  })

  scenario('returns idle state when no task has run', async () => {
    given('a fresh task runner')
    const runner = createTaskRunner('test-idle')

    when('getState is called')
    const state = await runner.getState()

    then('it returns idle state')
    expect(state.phase).toBe('idle')
    expect(state.current).toBe(0)
    expect(state.total).toBe(0)
    expect(state.message).toBe('')
    expect(state.startedAt).toBeNull()
    expect(state.completedAt).toBeNull()
  })

  scenario('marks task as failed when execute throws', async () => {
    given('a task runner with an item that throws')
    const runner = createTaskRunner('test-failure')
    const definition: TaskDefinition<string> = {
      items: async () => ['a'],
      execute: async () => {
        throw new Error('Something went wrong')
      },
      label: (item) => `Processing "${item}"`,
    }

    when('the task is started')
    const result = await runner.start(definition)

    then('it returns failed')
    expect(result).toBe('failed')

    and('the state reflects the failure')
    const state = await runner.getState()
    expect(state.phase).toBe('failed')
    expect(state.message).toContain('Something went wrong')
    expect(state.completedAt).toBeInstanceOf(Date)
  })

  scenario('reset clears state back to idle', async () => {
    given('a task runner that has completed a task')
    const runner = createTaskRunner('test-reset')
    const definition = createTestDefinition(['a'])
    await runner.start(definition)

    when('reset is called')
    await runner.reset()

    then('the state is back to idle')
    const state = await runner.getState()
    expect(state.phase).toBe('idle')
    expect(state.current).toBe(0)
    expect(state.total).toBe(0)
  })
})
