import SwiftUI

struct SeriesDetailContent: View {
    let name: String
    var rating: Int?
    let createdAt: Date
    let volumes: [Item]
    let onSelectBook: (String) -> Void
    var onRateSeries: () -> Void = {}

    var body: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(name)
                            .font(.title2.bold())
                        Text(
                            "\(volumes.count) \(volumes.count <= 1 ? "tome" : "tomes")"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if let rating {
                        if rating == 5 {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.red)
                                .font(.title3)
                        } else {
                            StarRatingView(rating: Double(rating))
                        }
                    }
                }
            }

            if rating == nil {
                Section {
                    Button { onRateSeries() } label: {
                        Label("Noter la série", systemImage: "star")
                    }
                }
            }

            if languageGroups.count > 1 {
                ForEach(languageGroups, id: \.language) { group in
                    Section {
                        ForEach(group.volumes) { volume in
                            volumeButton(volume)
                        }
                    } header: {
                        if let flag = group.flag {
                            Text(flag)
                        }
                    }
                }
            } else {
                Section("Tomes") {
                    ForEach(volumes) { volume in
                        volumeButton(volume)
                    }
                }
            }

            Section {
                LabeledContent("Ajoutée le") {
                    Text(
                        createdAt,
                        format: .dateTime.day().month(.wide).year()
                    )
                }
            }
        }
    }

    private func volumeButton(_ volume: Item) -> some View {
        Button { onSelectBook(volume.id) } label: {
            HStack {
                Text(verbatim: volume.label)
                    .font(.subheadline.monospaced())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(uiColor: .systemGray5))
                    .clipShape(.rect(cornerRadius: 6))
                Text(volume.title)
                    .lineLimit(1)
                Spacer()
                if let rating = volume.rating {
                    if rating == 5 {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                            .font(.caption)
                    } else {
                        StarRatingView(rating: Double(rating))
                            .font(.caption)
                    }
                }
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
        .tint(.primary)
    }

    private var languageGroups: [LanguageGroup] {
        let grouped = Dictionary(grouping: volumes) { $0.language ?? "" }
        return grouped.keys.sorted().map { language in
            LanguageGroup(
                language: language,
                flag: language.isEmpty ? nil : BookGrouping.flagEmoji(for: language),
                volumes: grouped[language] ?? []
            )
        }
    }
}

extension SeriesDetailContent {
    struct Item: Identifiable {
        let id: String
        let title: String
        let label: String
        let position: Double
        var language: String?
        var rating: Int?
    }

    private struct LanguageGroup {
        let language: String
        let flag: String?
        let volumes: [Item]
    }
}

#Preview("Multi-tomes") {
    SeriesDetailContent(
        name: "Les Rougon-Macquart",
        rating: 4,
        createdAt: Date(),
        volumes: [
            .init(
                id: "1", title: "La Fortune des Rougon", label: "1", position: 1, language: "fr",
                rating: 4),
            .init(id: "2", title: "La Curée", label: "2", position: 2, language: "fr"),
            .init(
                id: "3", title: "L'Assommoir", label: "7", position: 7, language: "fr", rating: 5),
        ],
        onSelectBook: { _ in }
    )
}

#Preview("Favori") {
    SeriesDetailContent(
        name: "Le Sorceleur",
        rating: 5,
        createdAt: Date(),
        volumes: [
            .init(
                id: "1", title: "Le Dernier Voeu", label: "1", position: 1, language: "fr",
                rating: 5),
            .init(
                id: "2", title: "The Last Wish", label: "1", position: 1, language: "en",
                rating: 4),
        ],
        onSelectBook: { _ in }
    )
}

#Preview("Sans note") {
    SeriesDetailContent(
        name: "Fondation",
        createdAt: Date(),
        volumes: [
            .init(id: "1", title: "Fondation", label: "1", position: 1, language: "fr"),
        ],
        onSelectBook: { _ in }
    )
}
