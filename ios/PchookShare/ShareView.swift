import SwiftUI

struct ShareView: View {
    @State var viewModel: ShareViewModel

    var body: some View {
        Group {
            switch viewModel.step {
            case .analyzing:
                analyzingContent

            case .preview(let preview):
                previewContent(preview)

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

    private func previewContent(_ preview: ShareBookPreview) -> some View {
        VStack(spacing: 0) {
            List {
                // Header
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(preview.title)
                            .font(.headline)
                        Text(preview.authors.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        if let genre = preview.genre {
                            HStack(spacing: 6) {
                                ForEach(
                                    genre.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
                                    id: \.self
                                ) { g in
                                    Text(g)
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.accentColor.opacity(0.15))
                                        .foregroundStyle(Color.accentColor)
                                        .clipShape(.capsule)
                                }
                            }
                        }
                    }

                    if let series = preview.series {
                        HStack(spacing: 8) {
                            Image(systemName: "books.vertical")
                                .foregroundStyle(.secondary)
                            Text(preview.seriesNumber.map { "\(series) — Tome \($0)" } ?? series)
                        }
                    }
                }

                // Ratings
                if !preview.publicRatings.isEmpty {
                    Section("Notes") {
                        ForEach(preview.publicRatings) { rating in
                            HStack {
                                Text(rating.source)
                                Text("(\(formattedVoterCount(rating.voterCount)))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(rating.score)/\(rating.maxScore)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                // Awards
                if !preview.awards.isEmpty {
                    Section("Prix littéraires") {
                        ForEach(preview.awards) { award in
                            HStack {
                                Image(systemName: "medal.fill")
                                    .foregroundStyle(.orange)
                                Text(award.name)
                                Spacer()
                                if let year = award.year {
                                    Text("\(year)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                // Info
                if preview.pageCount != nil || preview.format != nil || preview.language != nil {
                    Section("Informations") {
                        if let pageCount = preview.pageCount {
                            infoRow(icon: "doc.text", title: "Pages", value: "\(pageCount)")
                        }
                        if let format = preview.format {
                            infoRow(icon: "doc", title: "Format", value: format)
                        }
                        if let language = preview.language {
                            infoRow(icon: "globe", title: "Langue", value: language)
                        }
                        if let publisher = preview.publisher {
                            infoRow(icon: "building.2", title: "Éditeur", value: publisher)
                        }
                        if let estimatedPrice = preview.estimatedPrice {
                            infoRow(
                                icon: "eurosign.circle",
                                title: "Prix estimé",
                                value: String(format: "%.2f €", estimatedPrice)
                            )
                        }
                    }
                }

                // Synopsis
                if let synopsis = preview.synopsis {
                    Section("Synopsis") {
                        Text(synopsis)
                            .font(.subheadline)
                            .lineLimit(5)
                    }
                }
            }

            // CTAs
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button {
                        viewModel.confirm(previewId: preview.previewId, status: "to-read")
                    } label: {
                        Label("À lire", systemImage: "bookmark.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(viewModel.isConfirming)

                    Button {
                        viewModel.confirm(previewId: preview.previewId, status: "read")
                    } label: {
                        Label("Lu", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(viewModel.isConfirming)
                }

                Button {
                    viewModel.dismiss()
                } label: {
                    Text("Fermer")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding()
            .background(.bar)
        }
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
            LabeledContent(title, value: value)
        }
    }

    private func formattedVoterCount(_ count: Int) -> String {
        if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000.0)
        }
        return "\(count)"
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
                    Label("Réessayer", systemImage: "arrow.clockwise")
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
