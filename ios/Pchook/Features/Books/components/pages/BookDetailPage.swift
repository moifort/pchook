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
    @State private var isEditing = false

    var body: some View {
        NavigationStack {
            Group {
                if let detail {
                    if isEditing {
                        BookEditForm(
                            initial: editFields(from: detail),
                            onSave: { request in
                                _ = try await BooksAPI.update(id: bookId, request)
                                self.detail = try await BooksAPI.getDetail(id: bookId)
                                isEditing = false
                                onUpdated()
                            },
                            onCancel: { isEditing = false }
                        )
                    } else {
                        BookDetailContent(
                            detail: detail,
                            onAddReview: { showReviewSheet = true },
                            onRatingChanged: { rating in
                                let request = CreateReviewRequest(
                                    rating: rating,
                                    readDate: ISO8601DateFormatter().string(from: Date())
                                )
                                try? await BooksAPI.addReview(id: bookId, request)
                                await loadDetail()
                                onUpdated()
                            }
                        )
                        .refreshable { await loadDetail() }
                    }
                } else if let error {
                    ContentUnavailableView("Erreur", systemImage: "exclamationmark.triangle", description: Text(error))
                } else {
                    ProgressView("Chargement...")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sentryTrace("Book Detail")
            .toolbar {
                if !isEditing {
                    readToolbar
                }
            }
            .task { await loadDetail() }
            .sheet(isPresented: $showReviewSheet) {
                AddReviewSheet(bookId: bookId) {
                    showReviewSheet = false
                    await loadDetail()
                    onUpdated()
                }
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var readToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Fermer", systemImage: "xmark") { dismiss() }
        }
        if let detail, detail.review?.rating != 5 {
            ToolbarItemGroup {
                AsyncToolbarButton(title: "Ajouter aux favoris", systemImage: "heart") {
                    try? await BooksAPI.addToFavorites(id: bookId)
                    await loadDetail()
                    onUpdated()
                }
            }
        }
        if detail != nil {
            ToolbarItemGroup {
                Menu {
                    Button("Modifier", systemImage: "pencil") {
                        isEditing = true
                    }
                    Button("Ajouter un avis", systemImage: "star.bubble") {
                        showReviewSheet = true
                    }
                    Button("Supprimer", systemImage: "trash", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                    .accessibilityIdentifier("delete-book-button")
                } label: {
                    Image(systemName: "ellipsis")
                }
                .accessibilityIdentifier("book-detail-menu")
                .confirmationDialog(
                    "Supprimer ce livre ?",
                    isPresented: $showDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Supprimer", role: .destructive) {
                        Task { await deleteBook() }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func editFields(from detail: BookDetailData) -> BookEditForm.Fields {
        BookEditForm.Fields(
            title: detail.book.title,
            authors: detail.book.authors.joined(separator: ", "),
            genre: detail.book.genre ?? "",
            publisher: detail.book.publisher ?? "",
            pageCount: detail.book.pageCount.map(String.init) ?? "",
            isbn: detail.book.isbn ?? "",
            language: detail.book.language ?? "",
            format: detail.book.format ?? "",
            translator: detail.book.translator ?? "",
            estimatedPrice: detail.book.estimatedPrice.map { String(format: "%.2f", $0) } ?? "",
            synopsis: detail.book.synopsis ?? "",
            personalNotes: detail.book.personalNotes ?? ""
        )
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
