import SwiftUI

struct AwardBadge: View {
    let count: Int

    var body: some View {
        Label("\(count)", systemImage: "medal")
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color.yellow.opacity(0.15))
            .foregroundStyle(.orange)
            .clipShape(.capsule)
    }
}

#Preview {
    HStack {
        AwardBadge(count: 1)
        AwardBadge(count: 3)
    }
}
