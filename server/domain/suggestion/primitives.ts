import { make } from 'ts-brand'
import { z } from 'zod'
import type { SuggestionId as SuggestionIdType } from '~/domain/suggestion/types'

export const SuggestionId = (value: unknown) => {
  const v = z.string().uuid().parse(value)
  return make<SuggestionIdType>()(v)
}

export const randomSuggestionId = () => SuggestionId(crypto.randomUUID())
