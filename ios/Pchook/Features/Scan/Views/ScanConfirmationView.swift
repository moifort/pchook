import SwiftUI

struct ScanConfirmationView: View {
    let preview: Item
    let onScanAnother: () -> Void
    let onConfirm: (String) async -> Void

    @State private var isConfirming = false

    var body: some View {
        List {
            Section {
                LabeledInfoRow(title: "Titre", value: preview.title, icon: "book")
                LabeledInfoRow(title: "Auteurs", value: preview.authors, icon: "person.2")
                if let series = preview.series {
                    HStack {
                        LabeledInfoRow(
                            title: "Série",
                            value: preview.seriesNumber.map { "\(series) — Tome \($0)" } ?? series,
                            icon: "books.vertical"
                        )
                    }
                }
                if !preview.genres.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(preview.genres, id: \.self) { genre in
                            GenreBadge(genre: genre)
                        }
                    }
                }
            }

            if !preview.ratings.isEmpty {
                PublicRatingsSection(
                    ratings: preview.ratings,
                    userRating: nil
                )
            }

            if !preview.awards.isEmpty {
                AwardsSection(awards: preview.awards)
            }

            BookInfoSection(
                publisher: preview.publisher,
                pageCount: preview.pageCount,
                language: preview.language,
                format: preview.format,
                translator: preview.translator,
                estimatedPrice: preview.estimatedPrice,
                publishedDate: nil
            )

            BookSynopsisSection(synopsis: preview.synopsis)
        }
        .navigationTitle("Aperçu")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                Button {
                    onScanAnother()
                } label: {
                    Label("Scanner un autre", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .accessibilityIdentifier("scan-another-button")

                HStack(spacing: 12) {
                    Button {
                        isConfirming = true
                        Task {
                            await onConfirm("to-read")
                            isConfirming = false
                        }
                    } label: {
                        Label("À lire", systemImage: "bookmark.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(isConfirming)
                    .accessibilityIdentifier("status-to-read-button")

                    Button {
                        isConfirming = true
                        Task {
                            await onConfirm("read")
                            isConfirming = false
                        }
                    } label: {
                        Label("Lu", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(isConfirming)
                    .accessibilityIdentifier("status-read-button")
                }
            }
            .padding()
            .background(.bar)
        }
    }
}

extension ScanConfirmationView {
    struct Item: Sendable {
        let previewId: String
        let title: String
        let authors: String
        let genres: [String]
        let synopsis: String?
        let pageCount: Int?
        let language: String?
        let format: String?
        let publisher: String?
        let translator: String?
        let estimatedPrice: Double?
        let awards: [AwardsSection.Item]
        let ratings: [PublicRatingsSection.Item]
        let series: String?
        let seriesNumber: Int?
    }
}

#Preview {
    NavigationStack {
        ScanConfirmationView(
            preview: .init(
                previewId: "preview-1",
                title: "L'Étranger",
                authors: "Albert Camus",
                genres: ["Roman", "Philosophie"],
                synopsis: "Meursault, un employé de bureau à Alger, apprend la mort de sa mère. Il assiste aux funérailles sans montrer d'émotion apparente.",
                pageCount: 185,
                language: "Français",
                format: "pocket",
                publisher: "Gallimard",
                translator: nil,
                estimatedPrice: 6.90,
                awards: [.init(name: "Prix Nobel", year: 1957)],
                ratings: [.init(source: "Goodreads", score: 4, maxScore: 5, voterCount: 125_000)],
                series: nil,
                seriesNumber: nil
            ),
            onScanAnother: {},
            onConfirm: { _ in }
        )
    }
}
