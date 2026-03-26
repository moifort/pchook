import Sentry
import SentrySwiftUI
import SwiftUI

struct BooksPage: View {
    @Binding var refreshTrigger: Int

    @State private var viewModel = BooksViewModel()
    @State private var selectedBookId: String?
    @State private var scrollPosition: String?
    @State private var lastViewedBookId: String?
    @State private var itemChanged = false
    @State private var itemDeleted = false

    var body: some View {
        NavigationStack {
            Group {
                if !viewModel.hasBooks && viewModel.isLoading {
                    ProgressView("Chargement...")
                } else if let error = viewModel.error {
                    ContentUnavailableView("Erreur", systemImage: "exclamationmark.triangle", description: Text(error))
                } else if viewModel.isEmpty {
                    emptyState
                } else {
                    List {
                        favoriteSeriesSection

                        if viewModel.usesGrouping {
                            ForEach(viewModel.groupedBooks) { section in
                                Section {
                                    ForEach(section.items) { item in
                                        bookButton(item.book)
                                    }
                                } header: {
                                    HStack {
                                        Text(section.title)
                                        if let flag = section.flag {
                                            Text(flag)
                                        }
                                        Spacer()
                                        if let rating = section.rating {
                                            if rating == 5 {
                                                Image(systemName: "heart.fill")
                                                    .foregroundStyle(.red)
                                            } else {
                                                StarRatingView(rating: Double(rating))
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            ForEach(viewModel.books) { book in
                                bookButton(book)
                            }
                        }

                        if viewModel.hasMore {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .listRowSeparator(.hidden)
                                .task { await viewModel.loadMore() }
                        }
                    }
                    .scrollPosition(id: $scrollPosition)
                }
            }
            .navigationTitle(viewModel.isEmpty ? "" : viewModel.mode.title)
            .navigationSubtitle(viewModel.isEmpty ? "" : viewModel.navigationSubtitle)
            .navigationBarTitleDisplayMode(.large)
            .sentryTrace("Book List", waitForFullDisplay: true)
            .refreshable { await viewModel.load() }
            .task(id: "\(viewModel.filterKey)-\(refreshTrigger)") {
                await viewModel.load()
                SentrySDK.reportFullyDisplayed()
            }
            .toolbar {
                ToolbarItemGroup {
                    ForEach(BookListMode.allCases) { mode in
                        Button {
                            viewModel.mode = mode
                        } label: {
                            Label(mode.label, systemImage: mode.icon)
                        }
                        .tint(viewModel.mode == mode ? .accentColor : .primary)
                        .accessibilityIdentifier("booklist-mode-\(mode.rawValue)")
                    }
                }
                ToolbarSpacer(.fixed)
                ToolbarItemGroup {
                    Menu {
                        Picker("Tri", selection: $viewModel.sort) {
                            ForEach(BookSort.allCases) { sort in
                                Label(sort.label, systemImage: sort.icon).tag(sort)
                            }
                        }
                        Toggle(viewModel.sortDescending ? "Décroissant" : "Croissant", isOn: $viewModel.sortDescending)
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                    .accessibilityIdentifier("booklist-sort-menu")
                }
            }
            .sheet(
                item: Binding(
                    get: { selectedBookId.map { BookIdWrapper(id: $0) } },
                    set: { selectedBookId = $0?.id }
                ),
                onDismiss: { handleDetailDismiss() }
            ) { wrapper in
                BookDetailCoordinator(
                    bookId: wrapper.id,
                    onDeleted: { itemDeleted = true },
                    onUpdated: { itemChanged = true }
                )
                .onAppear { lastViewedBookId = wrapper.id }
            }
        }
    }

    @ViewBuilder
    private var favoriteSeriesSection: some View {
        if !viewModel.favoriteSeries.isEmpty {
            Section {
                ForEach(viewModel.favoriteSeries) { series in
                    Button {
                        selectedBookId = series.firstBookId
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                HStack(spacing: 6) {
                                    Text(series.name)
                                    if let flag = series.flag {
                                        Text(flag)
                                    }
                                }
                                Text("\(series.volumeCount) \(series.volumeCount <= 1 ? "tome" : "tomes")")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    .tint(.primary)
                }
            } header: {
                Text("Séries")
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        switch viewModel.mode {
        case .all:
            ContentUnavailableView(
                "Aucun livre",
                systemImage: "books.vertical",
                description: Text("Ajoutez des livres en scannant une couverture")
            )
        case .toRead:
            ContentUnavailableView(
                "Aucun livre à lire",
                systemImage: "bookmark",
                description: Text("Les livres à lire apparaîtront ici")
            )
        case .series:
            ContentUnavailableView(
                "Aucune série",
                systemImage: "list.number",
                description: Text("Les livres dans une série apparaîtront ici")
            )
        case .favorites:
            ContentUnavailableView(
                "Aucun favori",
                systemImage: "heart",
                description: Text("Notez des livres ou séries 5 étoiles")
            )
        }
    }

    private func handleDetailDismiss() {
        guard let bookId = lastViewedBookId else { return }
        if itemDeleted {
            viewModel.removeItem(id: bookId)
        } else if itemChanged {
            Task { await viewModel.updateItem(id: bookId) }
        }
        itemChanged = false
        itemDeleted = false
        lastViewedBookId = nil
    }

    @ViewBuilder
    private func bookButton(_ book: BookListItem) -> some View {
        Button {
            selectedBookId = book.id
        } label: {
            BookRow(
                title: book.title,
                subtitle: viewModel.subtitle(for: book),
                rating: book.rating,
                status: book.status
            )
        }
        .tint(.primary)
    }

}

struct BookIdWrapper: Identifiable {
    let id: String
}

#Preview {
    BooksPage(refreshTrigger: .constant(0))
}
