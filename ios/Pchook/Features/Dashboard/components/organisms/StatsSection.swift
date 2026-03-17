import SwiftUI

struct StatsSection: View {
    let total: Int
    let toRead: Int
    let read: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                GradientWidget(
                    title: "Total",
                    value: "\(total)",
                    subtitle: "Livres",
                    icon: "books.vertical",
                    gradient: [Color(red: 0.2, green: 0.4, blue: 0.7), Color(red: 0.4, green: 0.6, blue: 0.9)]
                )
                .accessibilityIdentifier("stat-total")

                GradientWidget(
                    title: "\u{00C0} lire",
                    value: "\(toRead)",
                    subtitle: "Livres",
                    icon: "bookmark",
                    gradient: [Color(red: 0.8, green: 0.5, blue: 0.2), Color(red: 0.95, green: 0.7, blue: 0.3)]
                )
                .accessibilityIdentifier("stat-to-read")
            }

            GradientWidget(
                title: "Lus",
                value: "\(read)",
                subtitle: "Livres termin\u{00E9}s",
                icon: "checkmark.circle",
                gradient: [Color(red: 0.15, green: 0.65, blue: 0.45), Color(red: 0.3, green: 0.8, blue: 0.55)]
            )
            .frame(height: 100)
            .accessibilityIdentifier("stat-read")
        }
    }
}

#Preview {
    StatsSection(total: 42, toRead: 14, read: 28)
        .padding()
}
