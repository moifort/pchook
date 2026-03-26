import { registerReviewEventHandlers } from '~/domain/review/event-handlers'
import { SearchCommand } from '~/domain/search/command'
import { registerSearchEventHandlers } from '~/domain/search/event-handlers'
import { registerSeriesEventHandlers } from '~/domain/series/event-handlers'

export default defineNitroPlugin(async () => {
  registerReviewEventHandlers()
  registerSeriesEventHandlers()
  registerSearchEventHandlers()
  await SearchCommand.rebuildAll()
})
