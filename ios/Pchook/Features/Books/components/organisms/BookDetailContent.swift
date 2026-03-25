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

#Preview {
    BookDetailContent(
        detail: BookDetailData(
            book: Book(
                id: "1",
                title: "Neuromancien",
                authors: ["William Gibson"],
                publisher: "J'ai Lu",
                pageCount: 320,
                genre: "Cyberpunk, Science-Fiction",
                synopsis: "Un hacker d\u{00E9}chu est recrut\u{00E9} pour une derni\u{00E8}re mission dans le cyberespace.",
                language: "fr",
                format: .pocket,
                translator: "Jean Bonnefoy",
                estimatedPrice: 8.50,
                narrators: [],
                status: .read,
                awards: [
                    Award(name: "Prix Nebula", year: 1984),
                    Award(name: "Prix Hugo", year: 1985),
                ],
                publicRatings: [
                    PublicRating(source: "Hardcover", score: 3.82, maxScore: 5, voterCount: 12000, url: "https://hardcover.app"),
                ],
                importSource: .scan,
                createdAt: Date(),
                updatedAt: Date()
            ),
            coverImageUrl: nil,
            series: SeriesInfo(
                id: "s1",
                name: "Sprawl",
                label: "Tome 1",
                position: 1,
                volumes: [
                    SeriesVolume(id: "1", title: "Neuromancien", label: "1", position: 1),
                    SeriesVolume(id: "2", title: "Compt\u{00E9} z\u{00E9}ro", label: "2", position: 2),
                    SeriesVolume(id: "3", title: "Mona Lisa s'\u{00E9}clate", label: "3", position: 3),
                ]
            ),
            review: ReviewInfo(bookId: "1", rating: 4, readDate: Date(), createdAt: Date())
        ),
        onAddReview: {},
        onSelectBook: { _ in }
    )
}
