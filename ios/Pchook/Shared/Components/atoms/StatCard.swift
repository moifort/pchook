import SwiftUI

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                Spacer()
                Text(value)
                    .font(.title.bold())
            }
            Spacer()
            Text(label)
                .font(.subheadline.weight(.medium))
        }
        .foregroundStyle(.white)
        .padding(12)
        .frame(minHeight: 80)
        .background(color.gradient, in: .rect(cornerRadius: 14))
    }
}

#Preview {
    LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 10) {
        StatCard(icon: "books.vertical", value: "152", label: "Total", color: .blue)
        StatCard(icon: "bookmark", value: "23", label: "Non lu", color: .orange)
        StatCard(icon: "headphones", value: "48h", label: "Audio", color: .purple)
        StatCard(icon: "checkmark.circle", value: "129", label: "Lu", color: .green)
    }
    .padding()
}
