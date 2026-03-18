import type { AudibleItem } from '~/domain/audible/types'
import { BookTitle } from '~/domain/book/primitives'
import type { Book, BookFormat, BookStatus } from '~/domain/book/types'
import { PersonName as makePersonName } from '~/domain/shared/primitives'
import type { PersonName } from '~/domain/shared/types'

export const formatDuration = (minutes: number) => {
  const hours = Math.floor(minutes / 60)
  const remainingMinutes = minutes % 60
  return `${hours}h ${remainingMinutes}min`
}

export const audibleItemToBookData = (item: AudibleItem, source: 'library' | 'wishlist') => {
  const status: BookStatus = source === 'library' ? 'read' : 'to-read'
  const format: BookFormat = 'audiobook'
  const authors: PersonName[] = item.authors.map((name) => makePersonName(name))
  const narrators: PersonName[] = item.narrators.map((name) => makePersonName(name))

  const data: Partial<Book> = {
    authors,
    status,
    format,
    narrators,
    duration: item.durationMinutes > 0 ? formatDuration(item.durationMinutes) : undefined,
    publisher: item.publisher ? (item.publisher as Book['publisher']) : undefined,
    language: item.language ? (item.language as Book['language']) : undefined,
    publishedDate: item.releaseDate,
  }

  return {
    title: BookTitle(item.title),
    data,
    seriesInfo: item.series ? { name: item.series.name, number: item.series.position } : undefined,
    coverUrl: item.coverUrl,
  }
}
