import { registerReviewEventHandlers } from '~/domain/review/event-handlers'
import { registerSeriesEventHandlers } from '~/domain/series/event-handlers'

export default defineNitroPlugin(() => {
  registerReviewEventHandlers()
  registerSeriesEventHandlers()
})
