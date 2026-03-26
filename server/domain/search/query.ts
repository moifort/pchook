import { uniq } from 'lodash-es'
import { searchEntries } from '~/domain/search/business-rules'
import * as index from '~/domain/search/index'
import type { SearchResults } from '~/domain/search/types'

export namespace SearchQuery {
  export const search = (query: string, limit = 20): SearchResults => {
    const matched = searchEntries(index.getEntries(), query, limit * 3)

    const bookIds = uniq(
      matched.filter(({ type }) => type === 'book').map(({ entityId }) => entityId),
    ).slice(0, limit)

    const seriesIds = uniq(
      matched.filter(({ type }) => type === 'series').map(({ entityId }) => entityId),
    ).slice(0, limit)

    const authorNames = uniq(
      matched.filter(({ type }) => type === 'author').map(({ entityId }) => entityId),
    ).slice(0, limit)

    return {
      books: bookIds.map((id) => index.getBookResult(id)).filter((result) => result !== undefined),
      series: seriesIds
        .map((id) => index.getSeriesResult(id))
        .filter((result) => result !== undefined),
      authors: authorNames
        .map((name) => index.getAuthorResult(name))
        .filter((result) => result !== undefined),
    }
  }
}
