import SwiftUI

struct EmojiPickerView: View {
    @Binding var isPresented: Bool
    let onEmojiSelected: (String) -> Void

    let emojiCategories: [String: [String]] = [
        "Hearts": ["❤️", "🧡", "💛", "💚", "💙", "💜", "🖤", "🤍", "🤎", "💖", "💝", "💗", "💓", "💞", "💕", "💌", "❣️", "💟"],
        "Smileys": ["😊", "😄", "😁", "🥰", "😍", "🤩", "😘", "😎", "🤗", "🥳", "😇", "✨", "⭐", "🌟", "💫"],
        "Hands": ["👍", "👏", "🙌", "👋", "🤝", "🙏", "💪", "✋", "🤚", "👌", "✌️", "🤘", "🤟", "🫶"],
        "Nature": ["🌸", "🌺", "🌻", "🌼", "🌷", "🌹", "🌿", "🍀", "🌈", "☀️", "🌙", "⭐", "🌟", "🔥", "💧"],
        "Objects": ["🎉", "🎊", "🎈", "🎁", "🎀", "🏆", "🥇", "🎯", "💎", "👑", "🎵", "🎶", "🎨", "✏️", "📝"]
    ]

    let categoryOrder = ["Hearts", "Smileys", "Hands", "Nature", "Objects"]

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Add Emoji")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.orange)

                Spacer()

                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 30)

            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    ForEach(categoryOrder, id: \.self) { category in
                        if let emojis = emojiCategories[category] {
                            VStack(alignment: .leading, spacing: 15) {
                                Text(category)
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 30)

                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 6), spacing: 15) {
                                    ForEach(emojis, id: \.self) { emoji in
                                        Button(action: {
                                            onEmojiSelected(emoji)
                                            isPresented = false
                                        }) {
                                            Text(emoji)
                                                .font(.system(size: 48))
                                                .frame(width: 80, height: 80)
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(16)
                                        }
                                    }
                                }
                                .padding(.horizontal, 30)
                            }
                        }
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .background(Color.white)
        .cornerRadius(24)
    }
}
