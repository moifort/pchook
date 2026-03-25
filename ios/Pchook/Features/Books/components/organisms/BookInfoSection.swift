import SwiftUI

struct BookInfoSection: View {
    let publisher: String?
    let pageCount: Int?
    let language: String?
    let format: BookFormat?
    let translator: String?
    let estimatedPrice: Double?
    let publishedDate: Date?
    let duration: String?
    let narrators: [String]?
    let importSource: ImportSource?
    let externalUrl: String?

    var body: some View {
        if hasContent {
            Section("Informations") {
                if let publisher {
                    LabeledInfoRow(title: "\u{00C9}diteur", value: publisher, icon: "building.2")
                }
                if let pageCount {
                    LabeledInfoRow(title: "Pages", value: "\(pageCount)", icon: "doc.text")
                }
                if let duration {
                    LabeledInfoRow(title: "Dur\u{00E9}e", value: duration, icon: "clock")
                }
                if let narrators, !narrators.isEmpty {
                    LabeledInfoRow(
                        title: "Narrateur(s)",
                        value: narrators.joined(separator: ", "),
                        icon: "person.wave.2"
                    )
                }
                if let language {
                    LabeledInfoRow(
                        title: "Langue",
                        value: BookLanguage(apiValue: language)?.label ?? language,
                        icon: "globe"
                    )
                }
                if let format {
                    LabeledInfoRow(
                        title: "Format",
                        value: format.label,
                        icon: "doc"
                    )
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
                        icon: "eurosign"
                    )
                }
                if let importSource {
                    if let externalUrl, let url = URL(string: externalUrl) {
                        Link(destination: url) {
                            LabeledInfoRow(title: "Origine", value: importSource.label, icon: importSource.icon)
                        }
                    } else {
                        LabeledInfoRow(title: "Origine", value: importSource.label, icon: importSource.icon)
                    }
                }
            }
        }
    }

    private var hasContent: Bool {
        publisher != nil || pageCount != nil || language != nil
            || format != nil || translator != nil || estimatedPrice != nil || publishedDate != nil
            || duration != nil || (narrators != nil && !(narrators?.isEmpty ?? true))
            || importSource != nil
    }
}

#Preview {
    List {
        BookInfoSection(
            publisher: "Gallimard",
            pageCount: 320,
            language: "fr",
            format: .pocket,
            translator: nil,
            estimatedPrice: 8.50,
            publishedDate: Date(),
            duration: nil,
            narrators: nil,
            importSource: .scan,
            externalUrl: nil
        )
    }
}
