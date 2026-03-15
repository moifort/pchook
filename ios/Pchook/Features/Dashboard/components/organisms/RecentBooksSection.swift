import SwiftUI

struct RecentBooksSection: View {
    let items: [Item]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Ajout\u{00E9}s r\u{00E9}cemment", systemImage: "clock")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                if !items.isEmpty {
                    Text("\(items.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if items.isEmpty {
                Text("Aucun livre r\u{00E9}cent")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(Color(.systemGray6))
                    .clipShape(.rect(cornerRadius: 12))
            } else {
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                Text(item.authors)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            if let genre = item.genre {
                                GenreBadge(genre: genre)
                            }
                            Text(item.createdAt.formatted(.dateTime.day(.twoDigits).month(.twoDigits)))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                    }
                }
                .background(Color(.systemGray6))
                .clipShape(.rect(cornerRadius: 12))
            }
        }
        .accessibilityIdentifier("dashboard-recent-section")
    }
}

extension RecentBooksSection {
    struct Item: Identifiable {
        let id: String
        let title: String
        let authors: String
        let genre: String?
        let createdAt: Date
    }
}

#Preview("Avec livres") {
    RecentBooksSection(
        items: [
            .init(id: "1", title: "L'\u{00C9}tranger", authors: "Albert Camus", genre: "Roman", createdAt: Date()),
            .init(id: "2", title: "Le Petit Prince", authors: "Antoine de Saint-Exup\u{00E9}ry", genre: "Conte", createdAt: Date().addingTimeInterval(-86400)),
        ]
    )
    .padding()
}

#Preview("Vide") {
    RecentBooksSection(items: [])
        .padding()
}
