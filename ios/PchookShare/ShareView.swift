import SwiftUI

struct ShareView: View {
    @State var viewModel: ShareViewModel

    var body: some View {
        Group {
            switch viewModel.step {
            case .analyzing:
                analyzingContent

            case .preview(let preview):
                NavigationStack {
                    SharePreviewForm(
                        preview: preview,
                        isConfirming: viewModel.isConfirming,
                        onConfirm: { status, overrides in
                            viewModel.confirm(previewId: preview.previewId, status: status, overrides: overrides)
                        },
                        onDismiss: { viewModel.dismiss() }
                    )
                }

            case .error(let message):
                errorContent(message: message)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.step)
        .onAppear {
            viewModel.start()
        }
    }

    private var analyzingContent: some View {
        VStack(spacing: 32) {
            Spacer()

            ProgressView()
                .scaleEffect(2)

            VStack(spacing: 12) {
                Text("Analyse en cours")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Identification du livre...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorContent(message: String) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)

            VStack(spacing: 8) {
                Text("Erreur")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    viewModel.retry()
                } label: {
                    Label("R\u{00E9}essayer", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button {
                    viewModel.dismiss()
                } label: {
                    Text("Annuler")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Editable Form

private struct SharePreviewForm: View {
    let preview: ShareBookPreview
    let isConfirming: Bool
    let onConfirm: (String, ShareConfirmOverrides?) -> Void
    let onDismiss: () -> Void

    @State private var title: String
    @State private var authors: String
    @State private var genre: String
    @State private var series: String
    @State private var seriesNumber: String
    @State private var publisher: String
    @State private var pageCount: String
    @State private var language: ShareBookLanguage?
    @State private var format: ShareBookFormat?
    @State private var translator: String
    @State private var estimatedPrice: String
    @State private var duration: String
    @State private var narrators: String
    @State private var synopsis: String

    init(
        preview: ShareBookPreview,
        isConfirming: Bool,
        onConfirm: @escaping (String, ShareConfirmOverrides?) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.preview = preview
        self.isConfirming = isConfirming
        self.onConfirm = onConfirm
        self.onDismiss = onDismiss
        _title = State(initialValue: preview.title)
        _authors = State(initialValue: preview.authors.joined(separator: ", "))
        _genre = State(initialValue: preview.genre ?? "")
        _series = State(initialValue: preview.series ?? "")
        _seriesNumber = State(initialValue: preview.seriesLabel ?? preview.seriesNumber.map { String($0) } ?? "")
        _publisher = State(initialValue: preview.publisher ?? "")
        _pageCount = State(initialValue: preview.pageCount.map { String($0) } ?? "")
        _language = State(initialValue: ShareBookLanguage(apiValue: preview.language))
        _format = State(initialValue: ShareBookFormat(apiValue: preview.format))
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

            if !preview.awards.isEmpty {
                Section("Prix litt\u{00E9}raires") {
                    ForEach(preview.awards) { award in
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(.orange)
                            Text(award.name)
                            Spacer()
                            if let year = award.year {
                                Text(verbatim: String(year))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
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

                Picker(selection: $language) {
                    Text("Non d\u{00E9}finie").tag(nil as ShareBookLanguage?)
                    ForEach(ShareBookLanguage.allCases) { lang in
                        Text(lang.label).tag(lang as ShareBookLanguage?)
                    }
                } label: {
                    Label("Langue", systemImage: "globe")
                }

                Picker(selection: $format) {
                    Text("Non d\u{00E9}fini").tag(nil as ShareBookFormat?)
                    ForEach(ShareBookFormat.allCases) { fmt in
                        Text(fmt.label).tag(fmt as ShareBookFormat?)
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
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Fermer", systemImage: "xmark") {
                    onDismiss()
                }
            }

            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    onConfirm("to-read", buildOverrides())
                } label: {
                    if isConfirming {
                        ProgressView()
                    } else {
                        Label("\u{00C0} lire", systemImage: "bookmark.fill")
                    }
                }
                .disabled(isConfirming)

                Button {
                    onConfirm("read", buildOverrides())
                } label: {
                    if isConfirming {
                        ProgressView()
                    } else {
                        Label("Lu", systemImage: "checkmark.circle.fill")
                    }
                }
                .disabled(isConfirming)
            }
        }
    }

    private func buildOverrides() -> ShareConfirmOverrides? {
        let editedAuthors = authors
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let editedGenre = genre.trimmingCharacters(in: .whitespaces)
        let originalGenre = (preview.genre ?? "").trimmingCharacters(in: .whitespaces)

        var overrides = ShareConfirmOverrides()
        var hasChanges = false

        if title != preview.title { overrides.title = title; hasChanges = true }
        if editedAuthors != preview.authors { overrides.authors = editedAuthors; hasChanges = true }
        if editedGenre != originalGenre { overrides.genre = editedGenre.isEmpty ? nil : editedGenre; hasChanges = true }
        let pub = publisher.trimmingCharacters(in: .whitespaces)
        if (pub.isEmpty ? nil : pub) != preview.publisher { overrides.publisher = pub.isEmpty ? nil : pub; hasChanges = true }
        if Int(pageCount) != preview.pageCount { overrides.pageCount = Int(pageCount); hasChanges = true }
        let syn = synopsis.trimmingCharacters(in: .whitespaces)
        if (syn.isEmpty ? nil : syn) != preview.synopsis { overrides.synopsis = syn.isEmpty ? nil : syn; hasChanges = true }
        if language?.rawValue != preview.language { overrides.language = language?.rawValue; hasChanges = true }
        if format?.rawValue != preview.format { overrides.format = format?.rawValue; hasChanges = true }
        let trans = translator.trimmingCharacters(in: .whitespaces)
        if (trans.isEmpty ? nil : trans) != preview.translator { overrides.translator = trans.isEmpty ? nil : trans; hasChanges = true }
        if Double(estimatedPrice) != preview.estimatedPrice { overrides.estimatedPrice = Double(estimatedPrice); hasChanges = true }
        let ser = series.trimmingCharacters(in: .whitespaces)
        if (ser.isEmpty ? nil : ser) != preview.series { overrides.series = ser.isEmpty ? nil : ser; hasChanges = true }
        let seriesLabelValue = seriesNumber.trimmingCharacters(in: .whitespaces)
        if (seriesLabelValue.isEmpty ? nil : seriesLabelValue) != preview.seriesLabel { overrides.seriesLabel = seriesLabelValue.isEmpty ? nil : seriesLabelValue; hasChanges = true }
        if Int(seriesNumber) != preview.seriesNumber { overrides.seriesNumber = Int(seriesNumber); hasChanges = true }

        return hasChanges ? overrides : nil
    }

}
