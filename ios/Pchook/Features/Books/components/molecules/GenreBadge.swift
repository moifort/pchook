import SwiftUI

struct GenreBadge: View {
    let genre: String

    var body: some View {
        Text(genre)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color.accentColor.opacity(0.15))
            .foregroundStyle(Color.accentColor)
            .clipShape(.capsule)
    }
}

#Preview {
    HStack {
        GenreBadge(genre: "Roman")
        GenreBadge(genre: "Science-Fiction")
        GenreBadge(genre: "Polar")
    }
}
