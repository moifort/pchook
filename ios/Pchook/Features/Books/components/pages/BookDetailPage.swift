import Sentry
import SentrySwiftUI
import SwiftUI

struct BookDetailPage: View {
    let bookId: String
    var refreshTrigger: Int = 0
    var onSelectBook: (String) -> Void = { _ in }
    var onDeleted: () -> Void = {}
    var onUpdated: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var detail: BookDetailData?
    @State private var error: String?
    @State private var showDeleteConfirmation = false
    @State private var showReviewSheet = false
    @State private var showRateSeriesSheet = false
    @State private var isDeleting = false
    @State private var isRefreshing = false
    @State private var isEditing = false

    var body: some View {
        Group {
            if let detail {
                if isEditing {
                    BookEditForm(
                        initial: BookEditForm.Fields(from: detail),
                        bookRating: detail.review?.rating,
                        seriesRating: detail.series?.rating,
                        onSave: { request in
                            _ = try await GraphQLBooksAPI.update(id: bookId, request)
                            self.detail = try await GraphQLBooksAPI.getDetail(id: bookId)
                            isEditing = false
                            onUpdated()
                        },
                        onCancel: { isEditing = false },
                        onRateBook: { showReviewSheet = true },
                        onRateSeries: { showRateSeriesSheet = true }
                    )
                } else {
                    BookDetailContent(
                        detail: detail,
                        onAddReview: { showReviewSheet = true },
                        onRateSeries: { showRateSeriesSheet = true },
                        onSelectBook: onSelectBook
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
        .navigationBarBackButtonHidden(isEditing)
        .sentryTrace("Book Detail")
        .toolbar {
            if !isEditing {
                readToolbar
            }
        }
        .task { await loadDetail() }
        .onChange(of: refreshTrigger) { Task { await loadDetail() } }
        .sheet(isPresented: $showReviewSheet) {
            AddReviewSheet(bookId: bookId) {
                showReviewSheet = false
                await loadDetail()
                onUpdated()
            }
        }
        .sheet(isPresented: $showRateSeriesSheet) {
            if let series = detail?.series {
                RateSeriesSheet(
                    seriesId: series.id,
                    seriesName: series.name,
                    initialRating: series.rating
                ) {
                    showRateSeriesSheet = false
                    await loadDetail()
                    onUpdated()
                }
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var readToolbar: some ToolbarContent {
        if let detail, detail.book.status == .toRead {
            ToolbarItemGroup {
                AsyncToolbarButton(title: "Marquer comme lu", systemImage: "checkmark.circle") {
                    _ = try? await GraphQLBooksAPI.update(id: bookId, UpdateBookRequest(status: "read"))
                    await loadDetail()
                    onUpdated()
                }
            }
        }
        if let detail, detail.review?.rating != 5 {
            ToolbarItemGroup {
                AsyncToolbarButton(title: "Ajouter aux favoris", systemImage: "heart") {
                    try? await GraphQLBooksAPI.addToFavorites(id: bookId)
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
        error = nil
        do {
            detail = try await GraphQLBooksAPI.getDetail(id: bookId)
        } catch {
            self.error = reportError(error)
        }
    }

    private func refreshEnrichment() async {
        isRefreshing = true
        do {
            try await GraphQLBooksAPI.refresh(id: bookId)
            detail = try await GraphQLBooksAPI.getDetail(id: bookId)
            onUpdated()
        } catch {
            self.error = reportError(error)
        }
        isRefreshing = false
    }

    private func deleteBook() async {
        isDeleting = true
        do {
            try await GraphQLBooksAPI.delete(id: bookId)
            onDeleted()
            dismiss()
        } catch {
            self.error = reportError(error)
        }
        isDeleting = false
    }
}
