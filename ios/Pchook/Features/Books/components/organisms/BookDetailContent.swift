import SwiftUI

struct BookDetailContent: View {
    let detail: BookDetailData
    let onAddReview: () -> Void
    let onSelectBook: (String) -> Void

    var body: some View {
        List {
            BookDetailHeader(
                title: detail.book.title,
                authors: detail.book.authors.joined(separator: ", "),
                genres: detail.book.genre?
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) } ?? [],
                status: detail.book.status,
                seriesPosition: detail.series?.position
            )

            if !detail.book.publicRatings.isEmpty || detail.review?.rating != nil {
                PublicRatingsSection(
                    ratings: detail.book.publicRatings.map {
                        .init(source: $0.source, score: $0.score, maxScore: $0.maxScore, voterCount: $0.voterCount)
                    },
                    userRating: detail.review?.rating
                )
            }

            if let series = detail.series {
                SeriesSection(
                    name: series.name,
                    currentPosition: series.position,
                    items: series.books.map { .init(id: $0.id, title: $0.title, position: $0.position) },
                    onSelectBook: onSelectBook
                )
            }

            if !detail.book.awards.isEmpty {
                AwardsSection(
                    awards: detail.book.awards.map { .init(name: $0.name, year: $0.year) }
                )
            }

            BookInfoSection(
                publisher: detail.book.publisher,
                pageCount: detail.book.pageCount,
                language: detail.book.language,
                format: detail.book.format,
                translator: detail.book.translator,
                estimatedPrice: detail.book.estimatedPrice,
                publishedDate: detail.book.publishedDate
            )

            BookSynopsisSection(
                synopsis: detail.book.synopsis
            )

            ReviewSection(
                review: detail.review.map {
                    .init(rating: $0.rating, readDate: $0.readDate)
                },
                personalNotes: detail.book.personalNotes,
                onAddReview: onAddReview
            )

            if !detail.suggestions.isEmpty {
                SuggestionsSection(
                    suggestions: detail.suggestions.map {
                        .init(
                            id: $0.id,
                            title: $0.title,
                            authors: $0.authors.joined(separator: ", "),
                            genre: $0.genre,
                            awardCount: $0.awards.count,
                            seriesPosition: nil
                        )
                    }
                )
            }
        }
    }
}
