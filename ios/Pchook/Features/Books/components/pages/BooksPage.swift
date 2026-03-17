import Sentry
import SentrySwiftUI
import SwiftUI

struct BooksPage: View {
    @State private var viewModel = BooksViewModel()
    @State private var selectedBookId: String?

    var body: some View {
        NavigationStack {
            Group {
                if !viewModel.hasBooks && viewModel.isLoading {
                    ProgressView("Chargement...")
                } else if viewModel.displayedBooks.isEmpty && !viewModel.hasBooks {
                    ContentUnavailableView(
                        "Aucun livre",
                        systemImage: "books.vertical",
                        description: Text("Ajoutez des livres en scannant une couverture")
                    )
                } else {
                    List {
                        ForEach(viewModel.displayedBooks) { book in
                            Button {
                                selectedBookId = book.id
                            } label: {
                                BookRow(
                                    title: book.title,
                                    authors: book.authors.joined(separator: ", "),
                                    genre: book.genre,
                                    rating: book.rating,
                                    status: book.status,
                                    awardCount: book.awards.count
                                )
                            }
                            .tint(.primary)
                        }
                    }
                }
            }
            .navigationTitle(viewModel.mode.title)
            .navigationBarTitleDisplayMode(.large)
            .sentryTrace("Book List", waitForFullDisplay: true)
            .refreshable { await viewModel.load() }
            .task(id: viewModel.filterKey) {
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
                        Toggle(viewModel.sortDescending ? "D\u{00E9}croissant" : "Croissant", isOn: $viewModel.sortDescending)

                        Divider()

                        Picker("Statut", selection: $viewModel.statusFilter) {
                            ForEach(BookStatusFilter.allCases) { filter in
                                Label(filter.label, systemImage: filter.icon).tag(filter)
                            }
                        }

                        Divider()

                        Picker("Cat\u{00E9}gorie", selection: Binding(
                            get: { viewModel.genreFilter ?? "" },
                            set: { viewModel.genreFilter = $0.isEmpty ? nil : $0 }
                        )) {
                            Label("Toutes", systemImage: "books.vertical").tag("")
                            ForEach(viewModel.availableGenres, id: \.self) { genre in
                                Text(genre).tag(genre)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                    .accessibilityIdentifier("booklist-sort-menu")
                }
            }
            .sheet(item: Binding(
                get: { selectedBookId.map { BookIdWrapper(id: $0) } },
                set: { selectedBookId = $0?.id }
            )) { wrapper in
                BookDetailPage(
                    bookId: wrapper.id,
                    onDeleted: { Task { await viewModel.load() } },
                    onUpdated: { Task { await viewModel.load() } }
                )
            }
        }
    }
}

struct BookIdWrapper: Identifiable {
    let id: String
}

#Preview {
    BooksPage()
}
