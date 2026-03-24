import * as repository from '~/domain/image/infrastructure/repository'
import { randomImageId } from '~/domain/image/primitives'
import type { ImageId } from '~/domain/image/types'

export namespace ImageCommand {
  export const save = async (buffer: Buffer) => {
    const id = randomImageId()
    await repository.save(id, buffer)
    return id
  }

  export const remove = async (id: ImageId) => {
    await repository.remove(id)
  }
}
