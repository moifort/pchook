import SwiftUI

struct SeriesDetailCoordinator: View {
    let seriesId: String
    var onUpdated: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var bookPath: [String] = []
    @State private var refreshTrigger = 0

    var body: some View {
        NavigationStack(path: $bookPath) {
            SeriesDetailPage(
                seriesId: seriesId,
                refreshTrigger: refreshTrigger,
                onSelectBook: { bookPath.append($0) },
                onUpdated: onUpdated
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer", systemImage: "xmark") { dismiss() }
                }
            }
            .navigationDestination(for: String.self) { selectedBookId in
                BookDetailPage(
                    bookId: selectedBookId,
                    onSelectBook: { bookPath.append($0) },
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
