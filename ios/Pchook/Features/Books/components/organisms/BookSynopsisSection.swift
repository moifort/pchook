import SwiftUI

struct BookSynopsisSection: View {
    let synopsis: String?
    let personalNotes: String?

    var body: some View {
        if synopsis != nil || personalNotes != nil {
            Section("Synopsis & Notes") {
                if let synopsis {
                    Label {
                        Text(synopsis)
                    } icon: {
                        Image(systemName: "text.quote")
                            .foregroundStyle(.secondary)
                    }
                }
                if let personalNotes {
                    Label {
                        Text(personalNotes)
                    } icon: {
                        Image(systemName: "note.text")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    List {
        BookSynopsisSection(
            synopsis: "Dans un futur proche, un hacker d\u{00E9}chu est recrut\u{00E9} pour une derni\u{00E8}re mission dans le cyberespace.",
            personalNotes: "Excellent roman fondateur du cyberpunk."
        )
    }
}
