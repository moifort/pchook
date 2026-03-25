import SwiftUI

struct BookSynopsisSection: View {
    let synopsis: String?

    var body: some View {
        if let synopsis {
            Section("Synopsis") {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "text.quote")
                        .foregroundStyle(.secondary)
                    Text(synopsis)
                }
            }
        }
    }
}

#Preview {
    List {
        BookSynopsisSection(
            synopsis: "Dans un futur proche, un hacker déchu est recruté pour une dernière mission dans le cyberespace."
        )
    }
}
