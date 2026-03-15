import SwiftUI

struct AwardsSection: View {
    let awards: [Item]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Prix litt\u{00E9}raires", systemImage: "medal")
                .font(.headline)

            VStack(spacing: 0) {
                ForEach(awards) { award in
                    HStack {
                        Image(systemName: "medal.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)
                        Text(award.name)
                            .font(.subheadline)
                        Spacer()
                        if let year = award.year {
                            Text("\(year)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                }
            }
            .background(Color(.systemGray6))
            .clipShape(.rect(cornerRadius: 12))
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
    AwardsSection(
        awards: [
            .init(name: "Prix Goncourt", year: 1957),
            .init(name: "Prix Nobel de Litt\u{00E9}rature", year: 1957),
        ]
    )
    .padding()
}
