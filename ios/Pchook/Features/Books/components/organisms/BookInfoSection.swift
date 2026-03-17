import SwiftUI

struct BookInfoSection: View {
    let publisher: String?
    let pageCount: Int?
    let language: String?
    let format: String?
    let translator: String?
    let estimatedPrice: Double?
    let publishedDate: Date?

    var body: some View {
        if hasContent {
            Section("Informations") {
                if let publisher {
                    LabeledInfoRow(title: "\u{00C9}diteur", value: publisher, icon: "building.2")
                }
                if let pageCount {
                    LabeledInfoRow(title: "Pages", value: "\(pageCount)", icon: "doc.text")
                }
                if let language {
                    LabeledInfoRow(title: "Langue", value: language, icon: "globe")
                }
                if let format {
                    LabeledInfoRow(title: "Format", value: format, icon: "doc")
                }
                if let translator {
                    LabeledInfoRow(title: "Traducteur", value: translator, icon: "person.2")
                }
                if let publishedDate {
                    LabeledInfoRow(
                        title: "Publication",
                        value: publishedDate.formatted(date: .abbreviated, time: .omitted),
                        icon: "calendar"
                    )
                }
                if let estimatedPrice {
                    LabeledInfoRow(
                        title: "Prix estim\u{00E9}",
                        value: String(format: "%.2f \u{20AC}", estimatedPrice),
                        icon: "eurosign.circle"
                    )
                }
            }
        }
    }

    private var hasContent: Bool {
        publisher != nil || pageCount != nil || language != nil
            || format != nil || translator != nil || estimatedPrice != nil || publishedDate != nil
    }
}

#Preview {
    List {
        BookInfoSection(
            publisher: "Gallimard",
            pageCount: 320,
            language: "Fran\u{00E7}ais",
            format: "pocket",
            translator: nil,
            estimatedPrice: 8.50,
            publishedDate: Date()
        )
    }
}
