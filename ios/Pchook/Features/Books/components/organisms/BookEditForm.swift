import SwiftUI

struct BookEditForm: View {
    let initial: Fields
    let onSave: (UpdateBookRequest) async throws -> Void
    let onCancel: () -> Void

    @State private var title: String
    @State private var authors: String
    @State private var genre: String
    @State private var publisher: String
    @State private var pageCount: String
    @State private var isbn: String
    @State private var language: BookLanguage?
    @State private var format: BookFormatOption?
    @State private var translator: String
    @State private var duration: String
    @State private var narrators: String
    @State private var estimatedPrice: String
    @State private var series: String
    @State private var seriesLabel: String
    @State private var seriesNumber: String
    @State private var synopsis: String
    @State private var personalNotes: String
    @State private var isSaving = false
    @State private var saveError: String?

    init(initial: Fields, onSave: @escaping (UpdateBookRequest) async throws -> Void, onCancel: @escaping () -> Void) {
        self.initial = initial
        self.onSave = onSave
        self.onCancel = onCancel
        _title = State(initialValue: initial.title)
        _authors = State(initialValue: initial.authors)
        _genre = State(initialValue: initial.genre)
        _publisher = State(initialValue: initial.publisher)
        _pageCount = State(initialValue: initial.pageCount)
        _isbn = State(initialValue: initial.isbn)
        _language = State(initialValue: BookLanguage(apiValue: initial.language))
        _format = State(initialValue: BookFormatOption(apiValue: initial.format))
        _translator = State(initialValue: initial.translator)
        _duration = State(initialValue: initial.duration)
        _narrators = State(initialValue: initial.narrators)
        _estimatedPrice = State(initialValue: initial.estimatedPrice)
        _series = State(initialValue: initial.series)
        _seriesLabel = State(initialValue: initial.seriesLabel)
        _seriesNumber = State(initialValue: initial.seriesNumber)
        _synopsis = State(initialValue: initial.synopsis)
        _personalNotes = State(initialValue: initial.personalNotes)
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
                    TextField("ISBN", text: $isbn)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Label("ISBN", systemImage: "barcode")
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

            Section("S\u{00E9}rie") {
                LabeledContent {
                    TextField("Nom de la s\u{00E9}rie", text: $series)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Label("S\u{00E9}rie", systemImage: "list.number")
                }

                LabeledContent {
                    TextField("Ex: Tome 1", text: $seriesLabel)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Label("Label", systemImage: "tag")
                }

                LabeledContent {
                    TextField("0", text: $seriesNumber)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Label("Position", systemImage: "number")
                }
            }

            Section("Synopsis & Notes") {
                TextField("Synopsis", text: $synopsis, axis: .vertical)
                    .lineLimit(3...8)
                TextField("Notes personnelles", text: $personalNotes, axis: .vertical)
                    .lineLimit(3...8)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler", systemImage: "xmark") {
                    onCancel()
                }
                .disabled(isSaving)
            }
            ToolbarItem(placement: .confirmationAction) {
                if isSaving {
                    ProgressView()
                } else {
                    Button("Enregistrer", systemImage: "checkmark") {
                        Task { await save() }
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .alert("Erreur", isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("OK") { saveError = nil }
        } message: {
            Text(saveError ?? "")
        }
    }

    private func save() async {
        isSaving = true
        let authorsList = authors
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let narratorsList = narrators
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let request = UpdateBookRequest(
            title: title,
            authors: authorsList.isEmpty ? nil : authorsList,
            publisher: publisher.isEmpty ? nil : publisher,
            pageCount: Int(pageCount),
            genre: genre.isEmpty ? nil : genre,
            synopsis: synopsis.isEmpty ? nil : synopsis,
            isbn: isbn.isEmpty ? nil : isbn,
            language: language?.rawValue,
            format: format?.rawValue,
            translator: translator.isEmpty ? nil : translator,
            estimatedPrice: Double(estimatedPrice),
            duration: format == .audiobook && !duration.isEmpty ? duration : nil,
            narrators: format == .audiobook && !narratorsList.isEmpty ? narratorsList : nil,
            personalNotes: personalNotes.isEmpty ? nil : personalNotes,
            series: series.isEmpty ? "" : series,
            seriesLabel: seriesLabel.isEmpty ? nil : seriesLabel,
            seriesNumber: Int(seriesNumber)
        )

        do {
            try await onSave(request)
        } catch {
            saveError = reportError(error)
        }
        isSaving = false
    }
}

extension BookEditForm {
    struct Fields {
        var title: String
        var authors: String
        var genre: String
        var publisher: String
        var pageCount: String
        var isbn: String
        var language: String
        var format: String
        var translator: String
        var estimatedPrice: String
        var duration: String
        var narrators: String
        var series: String
        var seriesLabel: String
        var seriesNumber: String
        var synopsis: String
        var personalNotes: String

        init(
            title: String, authors: String, genre: String, publisher: String,
            pageCount: String, isbn: String, language: String, format: String,
            translator: String, estimatedPrice: String, duration: String,
            narrators: String, series: String, seriesLabel: String, seriesNumber: String,
            synopsis: String, personalNotes: String
        ) {
            self.title = title
            self.authors = authors
            self.genre = genre
            self.publisher = publisher
            self.pageCount = pageCount
            self.isbn = isbn
            self.language = language
            self.format = format
            self.translator = translator
            self.estimatedPrice = estimatedPrice
            self.duration = duration
            self.narrators = narrators
            self.series = series
            self.seriesLabel = seriesLabel
            self.seriesNumber = seriesNumber
            self.synopsis = synopsis
            self.personalNotes = personalNotes
        }

        init(from detail: BookDetailData) {
            let position = detail.series?.position
            let positionString = position.map {
                $0.truncatingRemainder(dividingBy: 1) == 0
                    ? String(Int($0))
                    : String($0)
            } ?? ""

            self.init(
                title: detail.book.title,
                authors: detail.book.authors.joined(separator: ", "),
                genre: detail.book.genre ?? "",
                publisher: detail.book.publisher ?? "",
                pageCount: detail.book.pageCount.map(String.init) ?? "",
                isbn: detail.book.isbn ?? "",
                language: detail.book.language ?? "",
                format: detail.book.format ?? "",
                translator: detail.book.translator ?? "",
                estimatedPrice: detail.book.estimatedPrice.map { String(format: "%.2f", $0) } ?? "",
                duration: detail.book.duration ?? "",
                narrators: detail.book.narrators?.joined(separator: ", ") ?? "",
                series: detail.series?.name ?? "",
                seriesLabel: detail.series?.label ?? "",
                seriesNumber: positionString,
                synopsis: detail.book.synopsis ?? "",
                personalNotes: detail.book.personalNotes ?? ""
            )
        }
    }
}

#Preview {
    NavigationStack {
        BookEditForm(
            initial: .init(
                title: "Neuromancien",
                authors: "William Gibson",
                genre: "Cyberpunk, Science-Fiction",
                publisher: "J'ai Lu",
                pageCount: "320",
                isbn: "978-2-290-30540-0",
                language: "FR",
                format: "pocket",
                translator: "Jean Bonnefoy",
                estimatedPrice: "8.50",
                duration: "",
                narrators: "",
                series: "Sprawl",
                seriesLabel: "Tome 1",
                seriesNumber: "1",
                synopsis: "Un hacker d\u{00E9}chu est recrut\u{00E9} pour une derni\u{00E8}re mission.",
                personalNotes: "Excellent"
            ),
            onSave: { _ in },
            onCancel: {}
        )
    }
}
