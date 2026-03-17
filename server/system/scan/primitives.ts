import { make } from 'ts-brand'
import { z } from 'zod'
import type { ImageHash as ImageHashType, UrlHash as UrlHashType } from '~/system/scan/types'

export const ImageHash = (value: unknown) => {
  const v = z
    .string()
    .regex(/^[0-9a-f]{64}$/)
    .parse(value)
  return make<ImageHashType>()(v)
}

export const UrlHash = (value: unknown) => {
  const v = z
    .string()
    .regex(/^[0-9a-f]{64}$/)
    .parse(value)
  return make<UrlHashType>()(v)
}
