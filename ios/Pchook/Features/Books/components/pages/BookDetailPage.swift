import SwiftUI

struct BookDetailPage: View {
    let bookId: String
    var onDeleted: () -> Void = {}
    var onUpdated: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var seriesBookPath: [String] = []
    @State private var refreshTrigger = 0

    var body: some View {
        NavigationStack(path: $seriesBookPath) {
            BookDetailView(
                bookId: bookId,
                refreshTrigger: refreshTrigger,
                onSelectBook: { seriesBookPath.append($0) },
                onDeleted: onDeleted,
                onUpdated: onUpdated
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer", systemImage: "xmark") { dismiss() }
                }
            }
            .navigationDestination(for: String.self) { selectedBookId in
                BookDetailView(
                    bookId: selectedBookId,
                    onSelectBook: { seriesBookPath.append($0) },
                    onDeleted: {
                        refreshTrigger += 1
                        onUpdated()
                    },
                    onUpdated: {
                        refreshTrigger += 1
                        onUpdated()
                    }
                )
            }
        }
    }
}
