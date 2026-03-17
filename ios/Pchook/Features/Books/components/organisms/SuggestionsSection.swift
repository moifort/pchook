import SwiftUI

struct SuggestionsSection: View {
    let suggestions: [Item]

    var body: some View {
        Section("Vous pourriez aimer") {
            ForEach(suggestions) { suggestion in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(suggestion.title)
                            .lineLimit(1)
                        Text(suggestion.authors)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        if let genre = suggestion.genre {
                            ForEach(genre.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }, id: \.self) { subGenre in
                                GenreBadge(genre: subGenre)
                            }
                        }
                        if suggestion.awardCount > 0 {
                            AwardBadge(count: suggestion.awardCount)
                        }
                    }
                }
            }
        }
    }
}

extension SuggestionsSection {
    struct Item: Identifiable {
        let id: String
        let title: String
        let authors: String
        let genre: String?
        let awardCount: Int
    }
}

#Preview {
    List {
        SuggestionsSection(
            suggestions: [
                .init(id: "1", title: "La Peste", authors: "Albert Camus", genre: "Roman", awardCount: 1),
                .init(id: "2", title: "Les Fleurs du Mal", authors: "Charles Baudelaire", genre: "Po\u{00E9}sie", awardCount: 0),
            ]
        )
    }
}
