import SwiftUI

struct CoverImageView: View {
    let base64String: String?
    var maxHeight: CGFloat = 250

    var body: some View {
        if let base64String, let data = Data(base64Encoded: base64String), let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: maxHeight)
                .clipShape(.rect(cornerRadius: 12))
                .shadow(radius: 4)
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.2, green: 0.3, blue: 0.5), Color(red: 0.4, green: 0.5, blue: 0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 160, height: maxHeight)
                .overlay {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .shadow(radius: 4)
        }
    }
}

#Preview("With placeholder") {
    CoverImageView(base64String: nil)
}
