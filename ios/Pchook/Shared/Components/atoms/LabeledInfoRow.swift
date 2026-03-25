import SwiftUI

struct LabeledInfoRow: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        Label {
            LabeledContent(title, value: value)
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    List {
        LabeledInfoRow(title: "Genre", value: "Roman", icon: "tag")
        LabeledInfoRow(title: "Pages", value: "342", icon: "doc.text")
    }
}
