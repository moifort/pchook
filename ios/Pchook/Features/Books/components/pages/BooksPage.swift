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
                } else if viewModel.displayedBooks.isEmpty {
                    emptyState
                } else {
                    List {
                        if viewModel.usesGrouping {
                            ForEach(viewModel.groupedBooks) { section in
                                Section(section.title) {
                                    ForEach(section.items) { item in
                                        bookButton(item.book)
                                    }
                                }
                            }
                        } else {
                            ForEach(viewModel.displayedBooks) { book in
                                bookButton(book)
                            }
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
                onDismiss: { Task { await viewModel.load() } }
            ) { wrapper in
                BookDetailPage(bookId: wrapper.id)
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
                "Aucun livre \u{00E0} lire",
                systemImage: "bookmark",
                description: Text("Les livres \u{00E0} lire appara\u{00EE}tront ici")
            )
        case .read:
            ContentUnavailableView(
                "Aucun livre lu",
                systemImage: "checkmark.circle",
                description: Text("Les livres lus appara\u{00EE}tront ici")
            )
        case .favorites:
            ContentUnavailableView(
                "Aucun favori",
                systemImage: "heart",
                description: Text("Les livres not\u{00E9}s 5 \u{00E9}toiles appara\u{00EE}tront ici")
            )
        }
    }

    @ViewBuilder
    private func bookButton(_ book: BookListItem) -> some View {
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

struct BookIdWrapper: Identifiable {
    let id: String
}

#Preview {
    BooksPage()
}
