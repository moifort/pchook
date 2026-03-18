import SwiftUI

struct RecentAwardsSection: View {
    let items: [Item]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Prix r\u{00E9}cents", systemImage: "medal")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
            }

            if items.isEmpty {
                Text("Aucun prix r\u{00E9}cent")
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
                            Image(systemName: "medal.fill")
                                .foregroundStyle(.orange)
                                .font(.caption)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.bookTitle)
                                    .font(.subheadline)
                                    .lineLimit(1)
                                Text(item.authors)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(item.awardName)
                                    .font(.caption)
                                    .lineLimit(1)
                                Text(verbatim: String(item.awardYear))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
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
        .accessibilityIdentifier("dashboard-awards-section")
    }
}

extension RecentAwardsSection {
    struct Item: Identifiable {
        let bookTitle: String
        let authors: String
        let awardName: String
        let awardYear: Int

        var id: String { "\(bookTitle)-\(awardName)-\(awardYear)" }
    }
}

#Preview("Avec prix") {
    RecentAwardsSection(
        items: [
            .init(bookTitle: "L'\u{00C9}tranger", authors: "Albert Camus", awardName: "Prix Nobel", awardYear: 1957),
            .init(bookTitle: "Les Mis\u{00E9}rables", authors: "Victor Hugo", awardName: "Prix Goncourt", awardYear: 2024),
        ]
    )
    .padding()
}

#Preview("Vide") {
    RecentAwardsSection(items: [])
        .padding()
}
