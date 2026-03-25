import SwiftUI

struct AudibleEntryRow: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Previews

#Preview("With author and flag") {
    List {
        AudibleEntryRow(title: "Harry Potter à l'école des sorciers", subtitle: "J.K. Rowling · 🇬🇧")
        AudibleEntryRow(title: "Le Petit Prince", subtitle: "Antoine de Saint-Exupéry · 🇫🇷")
    }
}

#Preview("Author only") {
    List {
        AudibleEntryRow(title: "Dune", subtitle: "Frank Herbert")
    }
}

#Preview("No subtitle") {
    List {
        AudibleEntryRow(title: "Unknown Book", subtitle: nil)
    }
}
