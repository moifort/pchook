import SwiftUI

struct StatsSection: View {
    let total: Int
    let toRead: Int
    let read: Int
    let totalAudioMinutes: Int

    private var audioLabel: String {
        let hours = totalAudioMinutes / 60
        return "\(hours)h"
    }

    var body: some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 10) {
            StatCard(icon: "books.vertical", value: "\(total)", label: "Total", color: .blue)
            StatCard(icon: "bookmark", value: "\(toRead)", label: "Non lu", color: .orange)
            StatCard(icon: "headphones", value: audioLabel, label: "Audio", color: .purple)
            StatCard(icon: "checkmark.circle", value: "\(read)", label: "Lu", color: .green)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
}

#Preview {
    List {
        StatsSection(total: 152, toRead: 23, read: 129, totalAudioMinutes: 2880)
    }
}
