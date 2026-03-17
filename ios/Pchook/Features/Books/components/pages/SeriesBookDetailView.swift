import SwiftUI

struct SeriesBookDetailView: View {
    let bookId: String
    var onUpdated: () -> Void = {}

    @State private var detail: BookDetailData?
    @State private var error: String?
    @State private var showReviewSheet = false

    var body: some View {
        Group {
            if let detail {
                BookDetailContent(
                    detail: detail,
                    onAddReview: { showReviewSheet = true },
                    onSelectBook: { _ in }
                )
                .refreshable { await loadDetail() }
            } else if let error {
                ContentUnavailableView("Erreur", systemImage: "exclamationmark.triangle", description: Text(error))
            } else {
                ProgressView("Chargement...")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadDetail() }
        .sheet(isPresented: $showReviewSheet) {
            AddReviewSheet(bookId: bookId) {
                showReviewSheet = false
                await loadDetail()
                onUpdated()
            }
        }
    }

    private func loadDetail() async {
        do {
            detail = try await BooksAPI.getDetail(id: bookId)
        } catch {
            self.error = reportError(error)
        }
    }
}
