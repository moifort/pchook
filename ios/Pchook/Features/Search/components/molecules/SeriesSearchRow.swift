import SwiftUI

struct SeriesSearchRow: View {
    let name: String
    let volumeCount: Int
    let rating: Int?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "list.number")
                .font(.caption2)
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .lineLimit(2)
                Text("\(volumeCount) \(volumeCount <= 1 ? "tome" : "tomes")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let rating {
                if rating == 5 {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                } else {
                    StarRatingView(rating: Double(rating))
                }
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    List {
        SeriesSearchRow(name: "Fondation", volumeCount: 7, rating: 5)
        SeriesSearchRow(name: "Le Sorceleur", volumeCount: 8, rating: 4)
        SeriesSearchRow(name: "Dune", volumeCount: 3, rating: nil)
    }
}
