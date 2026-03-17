import SwiftUI

struct BookDetailContent: View {
    let detail: BookDetailData
    let onAddReview: () -> Void

    var body: some View {
        List {
            if let coverBase64 = detail.coverImageBase64 {
                Section {
                    CoverImageView(base64String: coverBase64)
                        .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.clear)
            }

            BookDetailHeader(
                title: detail.book.title,
                authors: detail.book.authors.joined(separator: ", "),
                genres: detail.book.genre?
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) } ?? [],
                status: detail.book.status
            )

            BookInfoSection(
                publisher: detail.book.publisher,
                pageCount: detail.book.pageCount,
                isbn: detail.book.isbn,
                language: detail.book.language,
                format: detail.book.format,
                translator: detail.book.translator,
                estimatedPrice: detail.book.estimatedPrice,
                publishedDate: detail.book.publishedDate
            )

            BookSynopsisSection(
                synopsis: detail.book.synopsis,
                personalNotes: detail.book.personalNotes
            )

            if let series = detail.series {
                SeriesSection(
                    name: series.name,
                    position: series.position,
                    books: series.books.map { .init(id: $0.id, title: $0.title, position: $0.position) }
                )
            }

            ReviewSection(
                review: detail.review.map {
                    .init(rating: $0.rating, readDate: $0.readDate, reviewNotes: $0.reviewNotes)
                },
                onAddReview: onAddReview
            )

            if !detail.book.publicRatings.isEmpty {
                PublicRatingsSection(
                    ratings: detail.book.publicRatings.map {
                        .init(source: $0.source, score: $0.score, maxScore: $0.maxScore, voterCount: $0.voterCount)
                    }
                )
            }

            if !detail.book.awards.isEmpty {
                AwardsSection(
                    awards: detail.book.awards.map { .init(name: $0.name, year: $0.year) }
                )
            }

            if !detail.suggestions.isEmpty {
                SuggestionsSection(
                    suggestions: detail.suggestions.map {
                        .init(
                            id: $0.id,
                            title: $0.title,
                            authors: $0.authors.joined(separator: ", "),
                            genre: $0.genre,
                            awardCount: $0.awards.count
                        )
                    }
                )
            }
        }
    }
}
