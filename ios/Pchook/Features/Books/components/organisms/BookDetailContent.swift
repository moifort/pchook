import SwiftUI

private func formatDuration(_ minutes: Int) -> String {
    let hours = minutes / 60
    let remainingMinutes = minutes % 60
    return "\(hours)h \(remainingMinutes)min"
}

struct BookDetailContent: View {
    let detail: BookDetailData
    let onAddReview: () -> Void
    let onSelectBook: (String) -> Void

    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    CoverImageView(imageUrl: detail.coverImageUrl)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }

            BookDetailHeader(
                title: detail.book.title,
                authors: detail.book.authors.joined(separator: ", "),
                genres: detail.book.genre?
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) } ?? [],
                status: detail.book.status,
                seriesLabel: detail.series?.label
            )

            RatingsSection(
                publicRatings: detail.book.publicRatings.map {
                    .init(source: $0.source, score: $0.score, maxScore: $0.maxScore, voterCount: $0.voterCount, url: $0.url)
                },
                userRating: detail.review?.rating,
                onAddReview: onAddReview
            )

            if let series = detail.series {
                SeriesSection(
                    name: series.name,
                    currentBookId: detail.book.id,
                    items: series.volumes.map { .init(id: $0.id, title: $0.title, label: $0.label, position: $0.position) },
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
                publishedDate: detail.book.publishedDate,
                duration: detail.book.durationMinutes.map { formatDuration($0) },
                narrators: detail.book.narrators,
                importSource: detail.book.importSource,
                externalUrl: detail.book.externalUrl
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

        }
    }
}
