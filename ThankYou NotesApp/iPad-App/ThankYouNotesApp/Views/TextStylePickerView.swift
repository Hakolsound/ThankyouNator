import SwiftUI

enum TextStyleType: String {
    case title = "Title"
    case paragraph = "Paragraph"
    case caption = "Caption"
}

struct TextStylePickerView: View {
    @Binding var isPresented: Bool
    let onStyleSelected: (TextStyleType) -> Void

    let styles: [(type: TextStyleType, icon: String)] = [
        (.title, "textformat.size"),
        (.paragraph, "text.alignleft"),
        (.caption, "text.quote"),
    ]

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Small popover menu attached to the left side
            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    ForEach(styles, id: \.type) { style in
                        Button(action: {
                            onStyleSelected(style.type)
                            isPresented = false
                        }) {
                            VStack(spacing: 2) {
                                Image(systemName: style.icon)
                                    .font(.system(size: 20))
                                Text(style.type.rawValue)
                                    .font(.system(size: 9))
                            }
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color(red: 0.2, green: 0.2, blue: 0.25))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.15, green: 0.15, blue: 0.2))
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                )

                // Arrow pointing to the button
                Triangle()
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.2))
                    .frame(width: 12, height: 12)
                    .rotationEffect(.degrees(-90))
                    .offset(x: -1, y: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.leading, 180) // Position right next to the text button
            .padding(.top, 260) // Aligned with text button
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            isPresented = false
        }
    }
}

#Preview {
    TextStylePickerView(isPresented: .constant(true)) { style in
        print("Selected: \(style)")
    }
}
