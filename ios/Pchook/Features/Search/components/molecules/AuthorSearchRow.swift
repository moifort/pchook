import SwiftUI

struct AuthorSearchRow: View {
    let name: String
    let bookCount: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: "person.fill")
                .font(.caption2)
                .foregroundStyle(.purple)
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .lineLimit(1)
                Text("\(bookCount) \(bookCount <= 1 ? "livre" : "livres")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    List {
        AuthorSearchRow(name: "Isaac Asimov", bookCount: 12)
        AuthorSearchRow(name: "Frank Herbert", bookCount: 1)
    }
}
