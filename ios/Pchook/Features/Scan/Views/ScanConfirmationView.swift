import SwiftUI

struct ScanConfirmationView: View {
    let preview: Item
    let onScanAnother: () -> Void
    let onConfirm: (String, ConfirmBookOverrides?) async -> Void

    @State private var title: String
    @State private var authors: String
    @State private var genre: String
    @State private var series: String
    @State private var seriesNumber: String
    @State private var publisher: String
    @State private var pageCount: String
    @State private var language: BookLanguage?
    @State private var format: BookFormatOption?
    @State private var translator: String
    @State private var estimatedPrice: String
    @State private var duration: String
    @State private var narrators: String
    @State private var synopsis: String

    init(
        preview: Item,
        onScanAnother: @escaping () -> Void,
        onConfirm: @escaping (String, ConfirmBookOverrides?) async -> Void
    ) {
        self.preview = preview
        self.onScanAnother = onScanAnother
        self.onConfirm = onConfirm
        _title = State(initialValue: preview.title)
        _authors = State(initialValue: preview.authors)
        _genre = State(initialValue: preview.genres.joined(separator: ", "))
        _series = State(initialValue: preview.series ?? "")
        _seriesNumber = State(initialValue: preview.seriesLabel ?? preview.seriesNumber.map { String($0) } ?? "")
        _publisher = State(initialValue: preview.publisher ?? "")
        _pageCount = State(initialValue: preview.pageCount.map { String($0) } ?? "")
        _language = State(initialValue: BookLanguage(apiValue: preview.language))
        _format = State(initialValue: BookFormatOption(apiValue: preview.format))
        _translator = State(initialValue: preview.translator ?? "")
        _estimatedPrice = State(initialValue: preview.estimatedPrice.map { String($0) } ?? "")
        _duration = State(initialValue: preview.duration ?? "")
        _narrators = State(initialValue: preview.narrators?.joined(separator: ", ") ?? "")
        _synopsis = State(initialValue: preview.synopsis ?? "")
    }

    var body: some View {
        Form {
            Section("Informations principales") {
                LabeledContent {
                    TextField("Titre", text: $title)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Label("Titre", systemImage: "book")
                }

                LabeledContent {
                    TextField("Auteurs", text: $authors)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Label("Auteurs", systemImage: "person.2")
                }

                LabeledContent {
                    TextField("Genre", text: $genre)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Label("Genre", systemImage: "tag")
                }
            }

            Section("S\u{00E9}rie") {
                LabeledContent {
                    TextField("Nom de la s\u{00E9}rie", text: $series)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Label("S\u{00E9}rie", systemImage: "books.vertical")
                }

                LabeledContent {
                    TextField("Tome", text: $seriesNumber)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Label("Tome", systemImage: "number")
                }
            }

            if !preview.ratings.isEmpty {
                PublicRatingsSection(
                    ratings: preview.ratings,
                    userRating: nil
                )
            }

            if !preview.awards.isEmpty {
                AwardsSection(awards: preview.awards)
            }

            Section("D\u{00E9}tails") {
                LabeledContent {
                    TextField("\u{00C9}diteur", text: $publisher)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Label("\u{00C9}diteur", systemImage: "building.2")
                }

                LabeledContent {
                    TextField("0", text: $pageCount)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Label("Pages", systemImage: "doc.text")
                }

                Picker(selection: $language) {
                    Text("Non d\u{00E9}finie").tag(nil as BookLanguage?)
                    ForEach(BookLanguage.allCases) { lang in
                        Text(lang.label).tag(lang as BookLanguage?)
                    }
                } label: {
                    Label("Langue", systemImage: "globe")
                }

                Picker(selection: $format) {
                    Text("Non d\u{00E9}fini").tag(nil as BookFormatOption?)
                    ForEach(BookFormatOption.allCases) { fmt in
                        Text(fmt.label).tag(fmt as BookFormatOption?)
                    }
                } label: {
                    Label("Format", systemImage: "doc")
                }

                if format == .audiobook {
                    LabeledContent {
                        TextField("Dur\u{00E9}e", text: $duration)
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Label("Dur\u{00E9}e", systemImage: "clock")
                    }

                    LabeledContent {
                        TextField("Narrateur(s)", text: $narrators)
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Label("Narrateur(s)", systemImage: "person.wave.2")
                    }
                }

                LabeledContent {
                    TextField("Traducteur", text: $translator)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Label("Traducteur", systemImage: "person.2")
                }

                LabeledContent {
                    HStack(spacing: 4) {
                        TextField("0", text: $estimatedPrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("\u{20AC}")
                            .foregroundStyle(.secondary)
                    }
                } label: {
                    Label("Prix", systemImage: "eurosign.circle")
                }
            }

            Section("Synopsis") {
                TextField("Synopsis", text: $synopsis, axis: .vertical)
                    .lineLimit(3...8)
            }
        }
        .navigationTitle("V\u{00E9}rifier le livre")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Scanner un autre", systemImage: "camera") {
                    onScanAnother()
                }
                .accessibilityIdentifier("scan-another-button")
            }

            ToolbarItemGroup(placement: .primaryAction) {
                AsyncToolbarButton(title: "\u{00C0} lire", systemImage: "bookmark.fill") {
                    await onConfirm("to-read", buildOverrides())
                }
                .accessibilityIdentifier("status-to-read-button")

                AsyncToolbarButton(title: "Lu", systemImage: "checkmark.circle.fill") {
                    await onConfirm("read", buildOverrides())
                }
                .accessibilityIdentifier("status-read-button")
            }
        }
    }

    private func buildOverrides() -> ConfirmBookOverrides? {
        let editedAuthors = authors
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let editedGenre = genre.trimmingCharacters(in: .whitespaces)
        let originalGenre = preview.genres.joined(separator: ", ")
        let editedNarrators = narrators
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        var overrides = ConfirmBookOverrides()
        var hasChanges = false

        if title != preview.title { overrides.title = title; hasChanges = true }
        if editedAuthors.joined(separator: ", ") != preview.authors { overrides.authors = editedAuthors; hasChanges = true }
        if editedGenre != originalGenre { overrides.genre = editedGenre; hasChanges = true }
        if publisher.nilIfEmpty != preview.publisher { overrides.publisher = publisher.nilIfEmpty; hasChanges = true }
        if Int(pageCount) != preview.pageCount { overrides.pageCount = Int(pageCount); hasChanges = true }
        if synopsis.nilIfEmpty != preview.synopsis { overrides.synopsis = synopsis.nilIfEmpty; hasChanges = true }
        if language?.rawValue != preview.language { overrides.language = language?.rawValue; hasChanges = true }
        if format?.rawValue != preview.format { overrides.format = format?.rawValue; hasChanges = true }
        if translator.nilIfEmpty != preview.translator { overrides.translator = translator.nilIfEmpty; hasChanges = true }
        if Double(estimatedPrice) != preview.estimatedPrice { overrides.estimatedPrice = Double(estimatedPrice); hasChanges = true }
        if series.nilIfEmpty != preview.series { overrides.series = series.nilIfEmpty; hasChanges = true }
        let seriesLabelValue = seriesNumber.nilIfEmpty
        if seriesLabelValue != preview.seriesLabel { overrides.seriesLabel = seriesLabelValue; hasChanges = true }
        if Int(seriesNumber) != preview.seriesNumber { overrides.seriesNumber = Int(seriesNumber); hasChanges = true }

        return hasChanges ? overrides : nil
    }
}

private extension String {
    var nilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? nil : trimmed
    }
}

extension ScanConfirmationView {
    struct Item: Sendable {
        let previewId: String
        var title: String
        var authors: String
        var genres: [String]
        var synopsis: String?
        var pageCount: Int?
        var language: String?
        var format: String?
        var publisher: String?
        var translator: String?
        var estimatedPrice: Double?
        var duration: String?
        var narrators: [String]?
        let awards: [AwardsSection.Item]
        let ratings: [PublicRatingsSection.Item]
        var series: String?
        var seriesLabel: String?
        var seriesNumber: Int?
    }
}

#Preview {
    NavigationStack {
        ScanConfirmationView(
            preview: .init(
                previewId: "preview-1",
                title: "L'\u{00C9}tranger",
                authors: "Albert Camus",
                genres: ["Roman", "Philosophie"],
                synopsis: "Meursault, un employ\u{00E9} de bureau \u{00E0} Alger.",
                pageCount: 185,
                language: "Fran\u{00E7}ais",
                format: "pocket",
                publisher: "Gallimard",
                translator: nil,
                estimatedPrice: 6.90,
                duration: nil,
                narrators: nil,
                awards: [.init(name: "Prix Nobel", year: 1957)],
                ratings: [.init(source: "Goodreads", score: 4.18, maxScore: 5, voterCount: 125_000)],
                series: nil,
                seriesNumber: nil
            ),
            onScanAnother: {},
            onConfirm: { _, _ in }
        )
    }
}
