import SwiftUI

struct RatingRow: View {
    let label: String
    let score: Double
    let maxScore: Double
    var voterCount: Int?
    var url: String?

    private var normalizedScore: Double {
        guard maxScore > 0 else { return 0 }
        return score / maxScore * 5.0
    }

    private var formattedScore: String {
        String(format: "%.2f/5", normalizedScore)
    }

    private var formattedVoterCount: String? {
        guard let count = voterCount else { return nil }
        if count >= 1000 {
            return String(format: "(%.1fk)", Double(count) / 1000.0)
        }
        return "(\(count))"
    }

    var body: some View {
        if let url = url.flatMap({ URL(string: $0) }) {
            Link(destination: url) {
                content
            }
        } else {
            content
        }
    }

    private var content: some View {
        HStack {
            Text(label)
            if let voters = formattedVoterCount {
                Text(voters)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(formattedScore)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview("Note publique") {
    List {
        RatingRow(
            label: "Sens Critique",
            score: 7.2,
            maxScore: 10,
            voterCount: 3400,
            url: "https://www.senscritique.com/search?query=9782266320481"
        )
    }
}

#Preview("Note utilisateur") {
    List {
        RatingRow(label: "Moi", score: 4, maxScore: 5)
    }
}

#Preview("Note Babelio") {
    List {
        RatingRow(
            label: "Babelio",
            score: 4.18,
            maxScore: 5,
            voterCount: 125000,
            url: "https://www.babelio.com/isbn/9782266320481"
        )
    }
}
