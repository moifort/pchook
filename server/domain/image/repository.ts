import type { ImageId } from '~/domain/image/types'

const storage = () => useStorage('images')

export const save = async (id: ImageId, buffer: Buffer) => {
  await storage().setItemRaw(id, buffer)
}

export const findById = async (id: ImageId) => (await storage().getItemRaw<Buffer>(id)) ?? undefined

export const exists = (id: ImageId) => storage().hasItem(id)

export const remove = async (id: ImageId) => {
  await storage().removeItem(id)
}
