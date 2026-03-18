import SwiftUI

struct ScanConfirmationView: View {
    let preview: Item
    let onScanAnother: () -> Void
    let onConfirm: (String, Item) async -> Void

    @State private var editablePreview: Item
    @State private var isConfirming = false
    @State private var isEditing = false

    init(preview: Item, onScanAnother: @escaping () -> Void, onConfirm: @escaping (String, Item) async -> Void) {
        self.preview = preview
        self.onScanAnother = onScanAnother
        self.onConfirm = onConfirm
        _editablePreview = State(initialValue: preview)
    }

    var body: some View {
        List {
            Section {
                LabeledInfoRow(title: "Titre", value: editablePreview.title, icon: "book")
                LabeledInfoRow(title: "Auteurs", value: editablePreview.authors, icon: "person.2")
                if let series = editablePreview.series {
                    LabeledInfoRow(
                        title: "S\u{00E9}rie",
                        value: editablePreview.seriesNumber.map { "\(series) \u{2014} Tome \($0)" } ?? series,
                        icon: "books.vertical"
                    )
                }
                if !editablePreview.genres.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(editablePreview.genres, id: \.self) { genre in
                            GenreBadge(genre: genre)
                        }
                    }
                }
            }

            if !editablePreview.ratings.isEmpty {
                PublicRatingsSection(
                    ratings: editablePreview.ratings,
                    userRating: nil
                )
            }

            if !editablePreview.awards.isEmpty {
                AwardsSection(awards: editablePreview.awards)
            }

            BookInfoSection(
                publisher: editablePreview.publisher,
                pageCount: editablePreview.pageCount,
                language: editablePreview.language,
                format: editablePreview.format,
                translator: editablePreview.translator,
                estimatedPrice: editablePreview.estimatedPrice,
                publishedDate: nil
            )

            BookSynopsisSection(synopsis: editablePreview.synopsis)
        }
        .navigationTitle("Aper\u{00E7}u")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Modifier", systemImage: "pencil") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            PreviewEditForm(
                initial: editablePreview,
                onSave: { updated in
                    editablePreview = updated
                    isEditing = false
                },
                onCancel: { isEditing = false }
            )
        }
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
                            await onConfirm("to-read", editablePreview)
                            isConfirming = false
                        }
                    } label: {
                        Label("\u{00C0} lire", systemImage: "bookmark.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(isConfirming)
                    .accessibilityIdentifier("status-to-read-button")

                    Button {
                        isConfirming = true
                        Task {
                            await onConfirm("read", editablePreview)
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
        var title: String
        var authors: String
        var genres: [String]
        var synopsis: String?
        var pageCount: Int?
        var language: String?
        var format: String?
        var publisher: String?
        var translator: String?
        var estimatedPrice: Double?
        let awards: [AwardsSection.Item]
        let ratings: [PublicRatingsSection.Item]
        var series: String?
        var seriesNumber: Int?
    }
}

#Preview {
    NavigationStack {
        ScanConfirmationView(
            preview: .init(
                previewId: "preview-1",
                title: "L'\u{00C9}tranger",
                authors: "Albert Camus",
                genres: ["Roman", "Philosophie"],
                synopsis: "Meursault, un employ\u{00E9} de bureau \u{00E0} Alger, apprend la mort de sa m\u{00E8}re. Il assiste aux fun\u{00E9}railles sans montrer d'\u{00E9}motion apparente.",
                pageCount: 185,
                language: "Fran\u{00E7}ais",
                format: "pocket",
                publisher: "Gallimard",
                translator: nil,
                estimatedPrice: 6.90,
                awards: [.init(name: "Prix Nobel", year: 1957)],
                ratings: [.init(source: "Goodreads", score: 4.18, maxScore: 5, voterCount: 125_000)],
                series: nil,
                seriesNumber: nil
            ),
            onScanAnother: {},
            onConfirm: { _, _ in }
        )
    }
}
