import { afterEach, describe, expect, mock, test } from 'bun:test'
import { clearHandlers, emit, on } from '~/system/event-bus'

describe('event-bus', () => {
  afterEach(() => {
    clearHandlers()
  })

  test('emit calls registered handlers', async () => {
    const handler = mock(async (_event: { value: number }) => {})
    on('test-event', handler)

    await emit('test-event', { value: 42 })

    expect(handler).toHaveBeenCalledWith({ value: 42 })
  })

  test('emit with no handlers does not throw', async () => {
    await expect(emit('unknown-event', {})).resolves.toBeUndefined()
  })

  test('multiple handlers on same event are all called', async () => {
    const firstHandler = mock(async (_event: { value: number }) => {})
    const secondHandler = mock(async (_event: { value: number }) => {})
    on('test-event', firstHandler)
    on('test-event', secondHandler)

    await emit('test-event', { value: 1 })

    expect(firstHandler).toHaveBeenCalledTimes(1)
    expect(secondHandler).toHaveBeenCalledTimes(1)
  })

  test('clearHandlers removes all registrations', async () => {
    const handler = mock(async (_event: { value: number }) => {})
    on('test-event', handler)

    clearHandlers()
    await emit('test-event', { value: 1 })

    expect(handler).not.toHaveBeenCalled()
  })
})
