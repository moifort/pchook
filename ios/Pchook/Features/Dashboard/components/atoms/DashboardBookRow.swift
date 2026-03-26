import SwiftUI

struct DashboardBookRow: View {
    let title: String
    var flag: String?
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .lineLimit(1)
                if let flag {
                    Text(flag)
                        .font(.caption)
                }
            }
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}
