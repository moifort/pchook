import { describe, expect, test } from 'bun:test'
import { Count, Eur, PersonName } from '~/domain/shared/primitives'

describe('Eur', () => {
  test('accepts a positive number', () => {
    expect(Eur(9.99)).toBe(Eur(9.99))
  })

  test('accepts zero', () => {
    expect(Eur(0)).toBe(Eur(0))
  })

  test('coerces a string to number', () => {
    expect(Eur('12.5')).toBe(Eur(12.5))
  })

  test('rejects a negative number', () => {
    expect(() => Eur(-1)).toThrow()
  })
})

describe('PersonName', () => {
  test('accepts a valid name', () => {
    expect(PersonName('Alice')).toBe(PersonName('Alice'))
  })

  test('rejects an empty string', () => {
    expect(() => PersonName('')).toThrow()
  })

  test('rejects a string longer than 200 characters', () => {
    expect(() => PersonName('a'.repeat(201))).toThrow()
  })
})

describe('Count', () => {
  test('wraps a number', () => {
    expect(Count(5)).toBe(Count(5))
  })
})
