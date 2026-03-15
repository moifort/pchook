import SwiftUI

struct SuggestionsSection: View {
    let suggestions: [Item]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Vous pourriez aimer", systemImage: "lightbulb")
                .font(.headline)

            VStack(spacing: 0) {
                ForEach(suggestions) { suggestion in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(suggestion.title)
                                .font(.subheadline)
                                .lineLimit(1)
                            Text(suggestion.authors)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        HStack(spacing: 6) {
                            if let genre = suggestion.genre {
                                GenreBadge(genre: genre)
                            }
                            if suggestion.awardCount > 0 {
                                AwardBadge(count: suggestion.awardCount)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                }
            }
            .background(Color(.systemGray6))
            .clipShape(.rect(cornerRadius: 12))
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
    SuggestionsSection(
        suggestions: [
            .init(id: "1", title: "La Peste", authors: "Albert Camus", genre: "Roman", awardCount: 1),
            .init(id: "2", title: "Les Fleurs du Mal", authors: "Charles Baudelaire", genre: "Po\u{00E9}sie", awardCount: 0),
        ]
    )
    .padding()
}
