import { expect } from 'bun:test'
import { BookCommand } from '~/domain/book/command'
import { BookTitle, Genre } from '~/domain/book/primitives'
import listHandler from '~/routes/books/index.get'
import { and, feature, given, scenario, then, when } from '~/test/bdd'
import { mockEvent } from '~/test/setup'

feature('GET /books', () => {
  scenario('lists all books', async () => {
    given('several books exist')
    await BookCommand.add(BookTitle('Germinal'), { genre: Genre('Roman naturaliste') })
    await BookCommand.add(BookTitle('Le Petit Prince'), { genre: Genre('Conte') })
    await BookCommand.add(BookTitle('Les Fleurs du Mal'), { genre: Genre('Poésie') })

    when('GET /books is called without filters')
    const event = mockEvent()
    const result = await listHandler(event as never)

    then('all books are returned')
    expect(result.status).toBe(200)
    expect(result.data).toHaveLength(3)
  })

  scenario('filters books by status', async () => {
    given('books with different statuses exist')
    await BookCommand.add(BookTitle('Germinal'), { status: 'to-read' })
    await BookCommand.add(BookTitle('Le Petit Prince'), { status: 'read' })
    await BookCommand.add(BookTitle('Les Fleurs du Mal'), { status: 'to-read' })

    when('GET /books is called with status=to-read')
    const event = mockEvent({ query: { status: 'to-read' } })
    const result = await listHandler(event as never)

    then('only to-read books are returned')
    expect(result.status).toBe(200)
    expect(result.data).toHaveLength(2)
    and('all returned books have status to-read')
    expect(result.data.every(({ status }) => status === 'to-read')).toBe(true)
  })

  scenario('sorts books by title ascending', async () => {
    given('several books exist')
    await BookCommand.add(BookTitle('Germinal'), {})
    await BookCommand.add(BookTitle('Les Fleurs du Mal'), {})
    await BookCommand.add(BookTitle('Anna Karénine'), {})

    when('GET /books is called with sort=title and order=asc')
    const event = mockEvent({ query: { sort: 'title', order: 'asc' } })
    const result = await listHandler(event as never)

    then('books are sorted alphabetically by title')
    expect(result.status).toBe(200)
    expect(result.data[0].title).toBe('Anna Karénine')
    and('the last book is the one with the latest alphabetical title')
    expect(result.data[2].title).toBe('Les Fleurs du Mal')
  })
})
