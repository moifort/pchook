import Sentry
import SentrySwiftUI
import SwiftUI

struct BookDetailPage: View {
    let bookId: String
    var onDeleted: () -> Void = {}
    var onUpdated: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var detail: BookDetailData?
    @State private var isLoading = true
    @State private var error: String?
    @State private var showDeleteConfirmation = false
    @State private var showReviewSheet = false
    @State private var isDeleting = false

    var body: some View {
        NavigationStack {
            Group {
                if let detail {
                    ScrollView {
                        VStack(spacing: 24) {
                            coverSection(detail.coverImageBase64)
                            bookInfoSection(detail.book)

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
                                onAddReview: { showReviewSheet = true }
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

                            actionsSection(detail.book)
                        }
                        .padding()
                    }
                } else if let error {
                    ContentUnavailableView("Erreur", systemImage: "exclamationmark.triangle", description: Text(error))
                } else {
                    ProgressView("Chargement...")
                }
            }
            .navigationTitle(detail?.book.title ?? "Livre")
            .navigationBarTitleDisplayMode(.inline)
            .sentryTrace("Book Detail")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
            .task { await loadDetail() }
            .refreshable { await loadDetail() }
            .confirmationDialog("Supprimer ce livre ?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Supprimer", role: .destructive) {
                    Task { await deleteBook() }
                }
            }
            .sheet(isPresented: $showReviewSheet) {
                AddReviewSheet(bookId: bookId) {
                    showReviewSheet = false
                    await loadDetail()
                    onUpdated()
                }
            }
        }
    }

    @ViewBuilder
    private func coverSection(_ coverBase64: String?) -> some View {
        CoverImageView(base64String: coverBase64)
            .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func bookInfoSection(_ book: Book) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(book.title)
                .font(.title2)
                .fontWeight(.bold)

            Text(book.authors.joined(separator: ", "))
                .font(.headline)
                .foregroundStyle(.secondary)

            if let publisher = book.publisher {
                LabeledInfoRow(title: "\u{00C9}diteur", value: publisher, icon: "building.2")
            }
            if let pageCount = book.pageCount {
                LabeledInfoRow(title: "Pages", value: "\(pageCount)", icon: "doc.text")
            }
            if let genre = book.genre {
                LabeledInfoRow(title: "Genre", value: genre, icon: "tag")
            }
            if let isbn = book.isbn {
                LabeledInfoRow(title: "ISBN", value: isbn, icon: "barcode")
            }
            if let language = book.language {
                LabeledInfoRow(title: "Langue", value: language, icon: "globe")
            }
            if let format = book.format {
                LabeledInfoRow(title: "Format", value: format, icon: "doc")
            }
            if let translator = book.translator {
                LabeledInfoRow(title: "Traducteur", value: translator, icon: "person.2")
            }
            if let price = book.estimatedPrice {
                LabeledInfoRow(title: "Prix estim\u{00E9}", value: String(format: "%.2f \u{20AC}", price), icon: "eurosign.circle")
            }
            if let synopsis = book.synopsis {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Synopsis")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(synopsis)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            if let notes = book.personalNotes {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes personnelles")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private func actionsSection(_ book: Book) -> some View {
        VStack(spacing: 12) {
            if book.status == "to-read" {
                Button {
                    Task { await markAsRead() }
                } label: {
                    Label("Marquer comme lu", systemImage: "checkmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .accessibilityIdentifier("mark-as-read-button")
            }

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Supprimer", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(isDeleting)
            .accessibilityIdentifier("delete-button")
        }
    }

    private func loadDetail() async {
        isLoading = true
        error = nil
        do {
            detail = try await BooksAPI.getDetail(id: bookId)
        } catch {
            self.error = reportError(error)
        }
        isLoading = false
    }

    private func markAsRead() async {
        do {
            let formatter = ISO8601DateFormatter()
            _ = try await BooksAPI.update(id: bookId, UpdateBookRequest(status: "read", readDate: formatter.string(from: Date())))
            await loadDetail()
            onUpdated()
        } catch {
            self.error = reportError(error)
        }
    }

    private func deleteBook() async {
        isDeleting = true
        do {
            try await BooksAPI.delete(id: bookId)
            onDeleted()
            dismiss()
        } catch {
            self.error = reportError(error)
        }
        isDeleting = false
    }
}
