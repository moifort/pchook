import SwiftUI

struct PreviewEditForm: View {
    let initial: ScanConfirmationView.Item
    let onSave: (ScanConfirmationView.Item) -> Void
    let onCancel: () -> Void

    @State private var title: String
    @State private var authors: String
    @State private var genre: String
    @State private var series: String
    @State private var seriesNumber: String
    @State private var publisher: String
    @State private var pageCount: String
    @State private var language: String
    @State private var format: String
    @State private var translator: String
    @State private var estimatedPrice: String
    @State private var synopsis: String

    init(
        initial: ScanConfirmationView.Item,
        onSave: @escaping (ScanConfirmationView.Item) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.initial = initial
        self.onSave = onSave
        self.onCancel = onCancel
        _title = State(initialValue: initial.title)
        _authors = State(initialValue: initial.authors)
        _genre = State(initialValue: initial.genres.joined(separator: ", "))
        _series = State(initialValue: initial.series ?? "")
        _seriesNumber = State(initialValue: initial.seriesNumber.map { String($0) } ?? "")
        _publisher = State(initialValue: initial.publisher ?? "")
        _pageCount = State(initialValue: initial.pageCount.map { String($0) } ?? "")
        _language = State(initialValue: initial.language ?? "")
        _format = State(initialValue: initial.format ?? "")
        _translator = State(initialValue: initial.translator ?? "")
        _estimatedPrice = State(initialValue: initial.estimatedPrice.map { String($0) } ?? "")
        _synopsis = State(initialValue: initial.synopsis ?? "")
    }

    var body: some View {
        NavigationStack {
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

                    LabeledContent {
                        TextField("Langue", text: $language)
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Label("Langue", systemImage: "globe")
                    }

                    LabeledContent {
                        TextField("Format", text: $format)
                            .multilineTextAlignment(.trailing)
                    } label: {
                        Label("Format", systemImage: "doc")
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
            .navigationTitle("Modifier")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler", systemImage: "xmark") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK", systemImage: "checkmark") {
                        onSave(buildItem())
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func buildItem() -> ScanConfirmationView.Item {
        let genres = genre
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        return .init(
            previewId: initial.previewId,
            title: title,
            authors: authors,
            genres: genres,
            synopsis: synopsis.isEmpty ? nil : synopsis,
            pageCount: Int(pageCount),
            language: language.isEmpty ? nil : language,
            format: format.isEmpty ? nil : format,
            publisher: publisher.isEmpty ? nil : publisher,
            translator: translator.isEmpty ? nil : translator,
            estimatedPrice: Double(estimatedPrice),
            awards: initial.awards,
            ratings: initial.ratings,
            series: series.isEmpty ? nil : series,
            seriesNumber: Int(seriesNumber)
        )
    }
}

#Preview {
    PreviewEditForm(
        initial: .init(
            previewId: "preview-1",
            title: "L'\u{00C9}tranger",
            authors: "Albert Camus",
            genres: ["Roman", "Philosophie"],
            synopsis: "Meursault, un employ\u{00E9} de bureau.",
            pageCount: 185,
            language: "Fran\u{00E7}ais",
            format: "pocket",
            publisher: "Gallimard",
            translator: nil,
            estimatedPrice: 6.90,
            awards: [],
            ratings: [],
            series: "Les Rougon-Macquart",
            seriesNumber: 3
        ),
        onSave: { _ in },
        onCancel: {}
    )
}
