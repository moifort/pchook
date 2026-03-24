import * as repository from '~/domain/image/repository'
import type { ImageId } from '~/domain/image/types'

export namespace ImageQuery {
  export const getById = (id: ImageId) => repository.findById(id)

  export const exists = (id: ImageId) => repository.exists(id)
}
