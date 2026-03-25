import SwiftUI

struct CoverImageView: View {
    let imageUrl: String?
    var maxHeight: CGFloat = 250

    var body: some View {
        if let imageUrl, let url = resolvedURL(imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: maxHeight)
                        .clipShape(.rect(cornerRadius: 12))
                        .shadow(radius: 4)
                case .failure:
                    placeholder
                default:
                    ProgressView()
                        .frame(maxHeight: maxHeight)
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
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

    private func resolvedURL(_ path: String) -> URL? {
        if path.hasPrefix("http") {
            return URL(string: path)
        }
        return APIClient.shared.baseURL.appendingPathComponent(path)
    }
}

#Preview("With placeholder") {
    CoverImageView(imageUrl: nil)
}
