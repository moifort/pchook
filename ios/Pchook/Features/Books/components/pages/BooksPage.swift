import Sentry
import SentrySwiftUI
import SwiftUI

struct BooksPage: View {
    @Binding var refreshTrigger: Int

    @State private var viewModel = BooksViewModel()
    @State private var selectedBookId: String?

    var body: some View {
        NavigationStack {
            Group {
                if !viewModel.hasBooks && viewModel.isLoading {
                    ProgressView("Chargement...")
                } else if let error = viewModel.error {
                    ContentUnavailableView("Erreur", systemImage: "exclamationmark.triangle", description: Text(error))
                } else if viewModel.displayedBooks.isEmpty {
                    emptyState
                } else {
                    List {
                        if viewModel.usesGrouping {
                            ForEach(viewModel.groupedBooks) { section in
                                Section {
                                    ForEach(section.items) { item in
                                        bookButton(item.book)
                                    }
                                } header: {
                                    HStack {
                                        Text(section.title)
                                        Spacer()
                                        if let flag = section.flag {
                                            Text(flag)
                                        }
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
            .navigationTitle(viewModel.displayedBooks.isEmpty ? "" : viewModel.mode.title)
            .navigationSubtitle(viewModel.displayedBooks.isEmpty ? "" : viewModel.mode.subtitle)
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
        case .series:
            ContentUnavailableView(
                "Aucune s\u{00E9}rie",
                systemImage: "list.number",
                description: Text("Les livres dans une s\u{00E9}rie appara\u{00EE}tront ici")
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
