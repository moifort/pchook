import SwiftUI

struct AudibleEntriesPage: View {
    @State private var entries: [AudibleEntryData]
    @State private var isLoading: Bool
    @State private var error: String?

    private let preloaded: Bool

    init() {
        _entries = State(initialValue: [])
        _isLoading = State(initialValue: true)
        preloaded = false
    }

    init(entries: [AudibleEntryData]) {
        _entries = State(initialValue: entries)
        _isLoading = State(initialValue: false)
        preloaded = true
    }

    private var sections: [EntrySection] {
        var seriesDict: [String: [AudibleEntryData]] = [:]
        var standalone: [AudibleEntryData] = []

        for entry in entries {
            if let seriesName = entry.seriesName {
                seriesDict[seriesName, default: []].append(entry)
            } else {
                standalone.append(entry)
            }
        }

        var result: [EntrySection] = seriesDict
            .sorted { $0.key.localizedCaseInsensitiveCompare($1.key) == .orderedAscending }
            .map { name, items in
                let sorted = items.sorted { ($0.seriesPosition ?? 0) < ($1.seriesPosition ?? 0) }
                let flag = sorted.first?.language.flatMap { BookGrouping.flagEmoji(for: $0) }
                return EntrySection(title: name, flag: flag, entries: sorted)
            }

        if !standalone.isEmpty {
            let sorted = standalone.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
            result.append(EntrySection(title: "Autres", flag: nil, entries: sorted))
        }

        return result
    }

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if let error {
                ContentUnavailableView(
                    "Erreur",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error)
                )
            } else {
                List {
                    ForEach(sections) { section in
                        Section {
                            ForEach(section.entries) { entry in
                                AudibleEntryRow(
                                    title: entry.title,
                                    subtitle: entrySubtitle(entry)
                                )
                            }
                        } header: {
                            HStack {
                                Text(section.title == "Autres" ? section.title : "Série : \(section.title)")
                                if let flag = section.flag {
                                    Text(flag)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Entrées Audible")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard !preloaded else { return }
            do {
                entries = try await GraphQLAudibleAPI.entries()
            } catch {
                self.error = reportError(error)
            }
            isLoading = false
        }
    }

    private func entrySubtitle(_ entry: AudibleEntryData) -> String? {
        let author = entry.authors.first
        let flag = entry.language.flatMap { BookGrouping.flagEmoji(for: $0) }

        return switch (author, flag) {
        case let (author?, flag?): "\(author) · \(flag)"
        case let (author?, nil): author
        case let (nil, flag?): flag
        case (nil, nil): nil as String?
        }
    }
}

// MARK: - Section Model

private struct EntrySection: Identifiable {
    let title: String
    let flag: String?
    let entries: [AudibleEntryData]

    var id: String { title + (flag ?? "") }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        AudibleEntriesPage(entries: [
            AudibleEntryData(
                title: "Harry Potter à l'école des sorciers",
                authors: ["J.K. Rowling"],
                language: "fr",
                seriesName: "Harry Potter",
                seriesPosition: 1,
                source: "library"
            ),
            AudibleEntryData(
                title: "Harry Potter et la chambre des secrets",
                authors: ["J.K. Rowling"],
                language: "fr",
                seriesName: "Harry Potter",
                seriesPosition: 2,
                source: "library"
            ),
            AudibleEntryData(
                title: "Dune",
                authors: ["Frank Herbert"],
                language: "fr",
                seriesName: "Dune",
                seriesPosition: 1,
                source: "library"
            ),
            AudibleEntryData(
                title: "Le Petit Prince",
                authors: ["Antoine de Saint-Exupéry"],
                language: "fr",
                source: "wishlist"
            ),
            AudibleEntryData(
                title: "Atomic Habits",
                authors: ["James Clear"],
                language: "en",
                source: "wishlist"
            ),
        ])
    }
}
