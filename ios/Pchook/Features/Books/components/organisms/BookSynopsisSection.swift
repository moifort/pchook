import SwiftUI

struct BookSynopsisSection: View {
    let synopsis: String?

    var body: some View {
        if let synopsis {
            Section("Synopsis") {
                Label {
                    Text(synopsis)
                } icon: {
                    Image(systemName: "text.quote")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    List {
        BookSynopsisSection(
            synopsis: "Dans un futur proche, un hacker d\u{00E9}chu est recrut\u{00E9} pour une derni\u{00E8}re mission dans le cyberespace."
        )
    }
}
