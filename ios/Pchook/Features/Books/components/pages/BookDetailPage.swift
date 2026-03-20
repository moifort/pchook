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
    @State private var isRefreshing = false
    @State private var isEditing = false
    @State private var seriesBookPath: [String] = []

    var body: some View {
        NavigationStack(path: $seriesBookPath) {
            Group {
                if let detail {
                    if isEditing {
                        BookEditForm(
                            initial: BookEditForm.Fields(from: detail),
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
                            onSelectBook: { seriesBookPath.append($0) }
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
            .navigationDestination(for: String.self) { selectedBookId in
                SeriesBookDetailView(bookId: selectedBookId, onDeleted: {
                    Task { await loadDetail() }
                    onUpdated()
                }, onUpdated: {
                    Task { await loadDetail() }
                    onUpdated()
                })
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
        if let detail, detail.book.status == "to-read" {
            ToolbarItemGroup {
                AsyncToolbarButton(title: "Marquer comme lu", systemImage: "checkmark.circle") {
                    _ = try? await BooksAPI.update(id: bookId, UpdateBookRequest(status: "read"))
                    await loadDetail()
                    onUpdated()
                }
            }
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
                    Button("Actualiser les données", systemImage: "arrow.trianglehead.2.clockwise") {
                        Task { await refreshEnrichment() }
                    }
                    .disabled(isRefreshing)
                    Button("Modifier", systemImage: "pencil") {
                        isEditing = true
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

    private func refreshEnrichment() async {
        isRefreshing = true
        do {
            try await BooksAPI.refresh(id: bookId)
            detail = try await BooksAPI.getDetail(id: bookId)
            onUpdated()
        } catch {
            self.error = reportError(error)
        }
        isRefreshing = false
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
