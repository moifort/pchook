import SwiftUI

struct StarRatingView: View {
    let rating: Double
    var total: Int = 5
    var font: Font = .caption2

    var body: some View {
        HStack(spacing: 1) {
            ForEach(1...total, id: \.self) { star in
                let value = Double(star)
                Image(systemName: starName(for: value))
                    .foregroundStyle(value - 0.5 <= rating ? .yellow : .gray.opacity(0.3))
                    .font(font)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Note : \(String(format: "%.1f", rating)) sur \(total)")
    }

    private func starName(for star: Double) -> String {
        if star <= rating {
            "star.fill"
        } else if star - 0.5 <= rating {
            "star.leadinghalf.filled"
        } else {
            "star"
        }
    }
}

#Preview("Aucune") {
    StarRatingView(rating: 0)
}

#Preview("3 sur 5") {
    StarRatingView(rating: 3)
}

#Preview("3.5 sur 5") {
    StarRatingView(rating: 3.5)
}

#Preview("5 sur 5") {
    StarRatingView(rating: 5)
}
