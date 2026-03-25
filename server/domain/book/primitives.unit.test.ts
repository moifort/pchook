import { describe, expect, test } from 'bun:test'
import {
  BookFormat,
  BookId,
  BookSort,
  BookStatus,
  BookTitle,
  Genre,
  ImportSource,
  ISBN,
  Language,
  Note,
  PageCount,
  Publisher,
  RatingScore,
  randomBookId,
  SortOrder,
} from '~/domain/book/primitives'

describe('BookId', () => {
  test('accepts a valid UUID', () => {
    const uuid = '550e8400-e29b-41d4-a716-446655440000'
    expect(BookId(uuid)).toBe(BookId(uuid))
  })

  test('rejects a non-UUID string', () => {
    expect(() => BookId('not-a-uuid')).toThrow()
  })

  test('rejects an empty string', () => {
    expect(() => BookId('')).toThrow()
  })
})

describe('randomBookId', () => {
  test('generates a valid BookId', () => {
    const id = randomBookId()
    expect(BookId(id)).toBe(id)
  })

  test('generates unique ids', () => {
    const id1 = randomBookId()
    const id2 = randomBookId()
    expect(id1).not.toBe(id2)
  })
})

describe('BookTitle', () => {
  test('accepts a valid title', () => {
    expect(BookTitle('Les Misérables')).toBe(BookTitle('Les Misérables'))
  })

  test('rejects an empty string', () => {
    expect(() => BookTitle('')).toThrow()
  })
})

describe('Publisher', () => {
  test('accepts a valid publisher name', () => {
    expect(Publisher('Gallimard')).toBe(Publisher('Gallimard'))
  })

  test('rejects an empty string', () => {
    expect(() => Publisher('')).toThrow()
  })
})

describe('Genre', () => {
  test('accepts a valid genre', () => {
    expect(Genre('Science Fiction')).toBe(Genre('Science Fiction'))
  })

  test('rejects an empty string', () => {
    expect(() => Genre('')).toThrow()
  })
})

describe('ISBN', () => {
  test('accepts a valid ISBN-10', () => {
    expect(ISBN('2070368225')).toBe(ISBN('2070368225'))
  })

  test('accepts a valid ISBN-13', () => {
    expect(ISBN('978-2-07-036822-8')).toBe(ISBN('978-2-07-036822-8'))
  })

  test('rejects a string shorter than 10 characters', () => {
    expect(() => ISBN('12345')).toThrow()
  })

  test('rejects a string longer than 17 characters', () => {
    expect(() => ISBN('123456789012345678')).toThrow()
  })

  test('rejects an empty string', () => {
    expect(() => ISBN('')).toThrow()
  })
})

describe('Language', () => {
  test('accepts a lowercase ISO 639-1 code', () => {
    expect(Language('fr')).toBe('fr')
    expect(Language('en')).toBe('en')
  })

  test('normalizes uppercase to lowercase', () => {
    expect(Language('FR')).toBe('fr')
    expect(Language('EN')).toBe('en')
  })

  test('rejects an unknown language code', () => {
    expect(() => Language('xx')).toThrow()
  })

  test('rejects an empty string', () => {
    expect(() => Language('')).toThrow()
  })
})

describe('PageCount', () => {
  test('accepts a positive integer', () => {
    expect(PageCount(320)).toBe(PageCount(320))
  })

  test('coerces a string to number', () => {
    expect(PageCount('250')).toBe(PageCount(250))
  })

  test('rejects zero', () => {
    expect(() => PageCount(0)).toThrow()
  })

  test('rejects a negative number', () => {
    expect(() => PageCount(-10)).toThrow()
  })

  test('rejects a non-integer', () => {
    expect(() => PageCount(3.5)).toThrow()
  })
})

describe('Note', () => {
  test('accepts zero', () => {
    expect(Note(0)).toBe(Note(0))
  })

  test('accepts 5', () => {
    expect(Note(5)).toBe(Note(5))
  })

  test('accepts a value in range', () => {
    expect(Note(3)).toBe(Note(3))
  })

  test('coerces a string to number', () => {
    expect(Note('4')).toBe(Note(4))
  })

  test('rejects a negative number', () => {
    expect(() => Note(-1)).toThrow()
  })

  test('accepts 10', () => {
    expect(Note(10)).toBe(Note(10))
  })

  test('rejects a number greater than 10', () => {
    expect(() => Note(11)).toThrow()
  })

  test('rounds a float to the nearest integer', () => {
    expect(Note(2.5)).toBe(Note(3))
    expect(Note(4.2)).toBe(Note(4))
    expect(Note(3.7)).toBe(Note(4))
  })
})

describe('RatingScore', () => {
  test('accepts an integer', () => {
    expect(RatingScore(5)).toBe(RatingScore(5))
  })

  test('preserves decimal values', () => {
    expect(RatingScore(3.75)).toBe(RatingScore(3.75))
    expect(RatingScore(4.18)).toBe(RatingScore(4.18))
  })

  test('accepts zero', () => {
    expect(RatingScore(0)).toBe(RatingScore(0))
  })

  test('accepts 10', () => {
    expect(RatingScore(10)).toBe(RatingScore(10))
  })

  test('coerces a string to number', () => {
    expect(RatingScore('3.75')).toBe(RatingScore(3.75))
  })

  test('rejects a negative number', () => {
    expect(() => RatingScore(-1)).toThrow()
  })

  test('rejects a number greater than 10', () => {
    expect(() => RatingScore(10.1)).toThrow()
  })
})

describe('BookFormat', () => {
  test('accepts pocket', () => {
    expect(BookFormat('pocket')).toBe('pocket')
  })

  test('accepts paperback', () => {
    expect(BookFormat('paperback')).toBe('paperback')
  })

  test('accepts hardcover', () => {
    expect(BookFormat('hardcover')).toBe('hardcover')
  })

  test('rejects an invalid format', () => {
    expect(() => BookFormat('ebook')).toThrow()
  })
})

describe('ImportSource', () => {
  test('accepts scan', () => {
    expect(ImportSource('scan')).toBe('scan')
  })

  test('accepts isbn', () => {
    expect(ImportSource('isbn')).toBe('isbn')
  })

  test('accepts url', () => {
    expect(ImportSource('url')).toBe('url')
  })

  test('accepts audible', () => {
    expect(ImportSource('audible')).toBe('audible')
  })

  test('rejects an invalid source', () => {
    expect(() => ImportSource('manual')).toThrow()
  })
})

describe('BookStatus', () => {
  test('accepts to-read', () => {
    expect(BookStatus('to-read')).toBe('to-read')
  })

  test('accepts read', () => {
    expect(BookStatus('read')).toBe('read')
  })

  test('rejects an invalid status', () => {
    expect(() => BookStatus('reading')).toThrow()
  })
})

describe('BookSort', () => {
  test('accepts createdAt', () => {
    expect(BookSort('createdAt')).toBe('createdAt')
  })

  test('accepts title', () => {
    expect(BookSort('title')).toBe('title')
  })

  test('accepts author', () => {
    expect(BookSort('author')).toBe('author')
  })

  test('accepts awards', () => {
    expect(BookSort('awards')).toBe('awards')
  })

  test('rejects an invalid sort field', () => {
    expect(() => BookSort('price')).toThrow()
  })
})

describe('SortOrder', () => {
  test('accepts asc', () => {
    expect(SortOrder('asc')).toBe('asc')
  })

  test('accepts desc', () => {
    expect(SortOrder('desc')).toBe('desc')
  })

  test('rejects an invalid order', () => {
    expect(() => SortOrder('random')).toThrow()
  })
})
