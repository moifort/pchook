import SwiftUI

struct FavoriteBooksSectionView: View {
    let items: [Item]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Mes favoris", systemImage: "heart.fill")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                if !items.isEmpty {
                    Text(verbatim: String(items.count))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if items.isEmpty {
                Text("Aucun favori")
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
                            StarRatingView(rating: Double(item.rating))
                            if let price = item.estimatedPrice {
                                Text(String(format: "%.0f €", price))
                                    .font(.subheadline)
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
        .accessibilityIdentifier("dashboard-favorites-section")
    }
}

extension FavoriteBooksSectionView {
    struct Item: Identifiable {
        let id: String
        let title: String
        let authors: String
        let genre: String?
        let rating: Int
        let estimatedPrice: Double?
    }
}

#Preview("Avec favoris") {
    FavoriteBooksSectionView(
        items: [
            .init(id: "1", title: "L'Étranger", authors: "Albert Camus", genre: "Roman", rating: 5, estimatedPrice: 7.50),
            .init(id: "2", title: "Le Petit Prince", authors: "Antoine de Saint-Exupéry", genre: "Conte", rating: 5, estimatedPrice: nil),
        ]
    )
    .padding()
}

#Preview("Vide") {
    FavoriteBooksSectionView(items: [])
        .padding()
}
