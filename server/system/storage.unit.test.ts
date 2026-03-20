import { describe, expect, test } from 'bun:test'
import { createTypedStorage } from '~/system/storage'

type TestEntity = {
  id: string
  name: string
  createdAt: Date
  updatedAt: Date
  deletedAt?: Date
}

describe('createTypedStorage', () => {
  const storage = () => createTypedStorage<TestEntity>('test-storage')

  test('getItem hydrates date fields from JSON strings', async () => {
    const entity: TestEntity = {
      id: '1',
      name: 'test',
      createdAt: new Date('2026-01-15T10:30:00.000Z'),
      updatedAt: new Date('2026-02-20T14:00:00.000Z'),
    }

    await storage().setItem('1', entity)
    const result = await storage().getItem('1')

    expect(result).not.toBeNull()
    expect(result?.createdAt).toBeInstanceOf(Date)
    expect(result?.updatedAt).toBeInstanceOf(Date)
    expect(result?.createdAt.toISOString()).toBe('2026-01-15T10:30:00.000Z')
    expect(result?.updatedAt.toISOString()).toBe('2026-02-20T14:00:00.000Z')
  })

  test('getItem returns null for missing key', async () => {
    const result = await storage().getItem('nonexistent')
    expect(result).toBeNull()
  })

  test('getItem preserves non-date string fields', async () => {
    const entity: TestEntity = {
      id: '2',
      name: 'not-a-date',
      createdAt: new Date(),
      updatedAt: new Date(),
    }

    await storage().setItem('2', entity)
    const result = await storage().getItem('2')

    expect(result?.name).toBe('not-a-date')
    expect(typeof result?.name).toBe('string')
  })

  test('getItem handles optional date fields', async () => {
    const entity: TestEntity = {
      id: '3',
      name: 'with-optional',
      createdAt: new Date('2026-03-01T00:00:00.000Z'),
      updatedAt: new Date('2026-03-01T00:00:00.000Z'),
      deletedAt: new Date('2026-03-15T12:00:00.000Z'),
    }

    await storage().setItem('3', entity)
    const result = await storage().getItem('3')

    expect(result?.deletedAt).toBeInstanceOf(Date)
    expect(result?.deletedAt?.toISOString()).toBe('2026-03-15T12:00:00.000Z')
  })

  test('getItem handles undefined optional date fields', async () => {
    const entity: TestEntity = {
      id: '4',
      name: 'no-optional',
      createdAt: new Date(),
      updatedAt: new Date(),
    }

    await storage().setItem('4', entity)
    const result = await storage().getItem('4')

    expect(result?.deletedAt).toBeUndefined()
  })

  test('getItems hydrates dates for all items', async () => {
    const s = storage()
    await s.setItem('a', {
      id: 'a',
      name: 'first',
      createdAt: new Date('2026-01-01T00:00:00.000Z'),
      updatedAt: new Date('2026-01-01T00:00:00.000Z'),
    })
    await s.setItem('b', {
      id: 'b',
      name: 'second',
      createdAt: new Date('2026-02-01T00:00:00.000Z'),
      updatedAt: new Date('2026-02-01T00:00:00.000Z'),
    })

    const items = await s.getItems(['a', 'b'])

    expect(items).toHaveLength(2)
    expect(items[0].value.createdAt).toBeInstanceOf(Date)
    expect(items[1].value.createdAt).toBeInstanceOf(Date)
  })

  test('getItems skips missing keys', async () => {
    await storage().setItem('exists', {
      id: 'exists',
      name: 'here',
      createdAt: new Date(),
      updatedAt: new Date(),
    })

    const items = await storage().getItems(['exists', 'missing'])

    expect(items).toHaveLength(1)
    expect(items[0].key).toBe('exists')
  })
})
