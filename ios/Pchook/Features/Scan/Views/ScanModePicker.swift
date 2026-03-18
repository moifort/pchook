import SwiftUI

enum ScanMode: String, CaseIterable {
    case barcode
    case photo

    var label: String {
        switch self {
        case .barcode: "Code-barres"
        case .photo: "Photo"
        }
    }
}

struct ScanModePicker: View {
    @Binding var selectedMode: ScanMode

    var body: some View {
        HStack(spacing: 24) {
            ForEach(ScanMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMode = mode
                    }
                } label: {
                    Text(mode.label)
                        .font(.subheadline.weight(selectedMode == mode ? .bold : .regular))
                        .foregroundStyle(selectedMode == mode ? .yellow : .white)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black
        ScanModePicker(selectedMode: .constant(.barcode))
    }
}
