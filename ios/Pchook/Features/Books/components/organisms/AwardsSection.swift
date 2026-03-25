import SwiftUI

struct AwardsSection: View {
    let awards: [Item]

    var body: some View {
        Section("Prix littéraires") {
            ForEach(awards) { award in
                HStack {
                    Image(systemName: "trophy").foregroundStyle(.secondary)
                    Text(award.name)
                    Spacer()
                    if let year = award.year {
                        Text(verbatim: String(year))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

extension AwardsSection {
    struct Item: Identifiable {
        let name: String
        let year: Int?

        var id: String { "\(name)-\(year ?? 0)" }
    }
}

#Preview {
    List {
        AwardsSection(
            awards: [
                .init(name: "Prix Goncourt", year: 1957),
                .init(name: "Prix Nobel de Littérature", year: 1957),
            ]
        )
    }
}
