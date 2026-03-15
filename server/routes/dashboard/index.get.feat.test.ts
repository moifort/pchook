import { expect } from 'bun:test'
import { BookCommand } from '~/domain/book/command'
import { BookTitle, Genre, Note } from '~/domain/book/primitives'
import type { BookId } from '~/domain/book/types'
import { ReviewCommand } from '~/domain/review/command'
import dashboardHandler from '~/routes/dashboard/index.get'
import { and, feature, given, scenario, then, when } from '~/test/bdd'
import { mockEvent } from '~/test/setup'

feature('GET /dashboard', () => {
  scenario('returns dashboard with book counts, favorites, and recent books', async () => {
    given('several books exist')
    const book1 = await BookCommand.add(BookTitle('Germinal'), {
      genre: Genre('Roman naturaliste'),
      status: 'read',
    })
    const book2 = await BookCommand.add(BookTitle('Le Petit Prince'), {
      genre: Genre('Conte'),
      status: 'to-read',
    })
    await BookCommand.add(BookTitle('Les Fleurs du Mal'), {
      genre: Genre('Poésie'),
      status: 'read',
    })

    and('some books have reviews')
    await ReviewCommand.create({
      bookId: book1.id as BookId,
      rating: Note(5),
      createdAt: new Date(),
    })
    await ReviewCommand.create({
      bookId: book2.id as BookId,
      rating: Note(3),
      createdAt: new Date(),
    })

    when('GET /dashboard is called')
    const event = mockEvent()
    const result = await dashboardHandler(event as never)

    then('book counts are correct')
    expect(result.status).toBe(200)
    expect(result.data.bookCount.total).toBe(3)
    expect(result.data.bookCount.read).toBe(2)
    expect(result.data.bookCount.toRead).toBe(1)

    and('favorites include only books with rating 5')
    expect(result.data.favorites).toHaveLength(1)
    expect(result.data.favorites[0].title).toBe('Germinal')
    expect(Number(result.data.favorites[0].rating)).toBe(5)

    and('recent books are returned')
    expect(result.data.recentBooks).toHaveLength(3)
  })
})
