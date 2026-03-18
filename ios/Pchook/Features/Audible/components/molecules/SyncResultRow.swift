import SwiftUI

struct SyncResultRow: View {
    let label: String
    let value: Int
    let icon: String

    var body: some View {
        HStack {
            Label(label, systemImage: icon)
            Spacer()
            Text("\(value)")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    List {
        SyncResultRow(label: "Livres ajoutés", value: 12, icon: "plus.circle")
        SyncResultRow(label: "Doublons ignorés", value: 3, icon: "arrow.triangle.2.circlepath")
    }
}
