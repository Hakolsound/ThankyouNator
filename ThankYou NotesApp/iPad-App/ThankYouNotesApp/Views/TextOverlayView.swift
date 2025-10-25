import SwiftUI

struct TextOverlayView: View {
    @Binding var isPresented: Bool
    let textStyleType: TextStyleType
    @State private var text: String = ""
    @State private var selectedColor: Color = .white
    @State private var selectedStyle: TextStyle = .bold
    @State private var selectedFont: TextFont = .system
    @State private var textAlignment: TextAlignment = .leading
    @State private var showColorPicker = false

    let onTextAdded: (String, Color, TextStyle, String) -> Void // Added font name parameter

    enum TextFont: String, CaseIterable {
        case system = "Classic"
        case rounded = "Rounded"
        case serif = "Serif"
        case typewriter = "Typewriter"
        case handwritten = "Handwritten"
        case modern = "Modern"
        case bold = "Strong"
        case script = "Script"

        var fontName: String {
            switch self {
            case .system: return "System"
            case .rounded: return "Avenir Next Rounded"
            case .serif: return "Georgia"
            case .typewriter: return "Courier"
            case .handwritten: return "Bradley Hand"
            case .modern: return "Futura"
            case .bold: return "Avenir Next Bold"
            case .script: return "Snell Roundhand"
            }
        }

        func font(size: CGFloat) -> Font {
            switch self {
            case .system:
                return .system(size: size, weight: .bold, design: .default)
            case .rounded:
                return .custom("Avenir Next Rounded", size: size)
            case .serif:
                return .custom("Georgia", size: size)
            case .typewriter:
                return .custom("Courier", size: size)
            case .handwritten:
                return .custom("Bradley Hand", size: size)
            case .modern:
                return .custom("Futura", size: size)
            case .bold:
                return .custom("Avenir Next Bold", size: size)
            case .script:
                return .custom("Snell Roundhand", size: size)
            }
        }
    }

    // Computed properties for different text types
    private var headerTitle: String {
        switch textStyleType {
        case .title: return "Add Title"
        case .paragraph: return "Add Paragraph"
        case .caption: return "Add Caption"
        }
    }

    private var placeholderText: String {
        switch textStyleType {
        case .title: return "Type your title..."
        case .paragraph: return "Type your paragraph..."
        case .caption: return "Type your caption..."
        }
    }

    private var inputPlaceholder: String {
        switch textStyleType {
        case .title: return "Your title here"
        case .paragraph: return "Your paragraph here"
        case .caption: return "Your caption here"
        }
    }

    enum TextStyle {
        case bold, outline, shadow
    }

    let presetColors: [Color] = [
        .white, .black, .red, .orange, .yellow, .green, .blue, .purple, .pink
    ]

    var body: some View {
        GeometryReader { geometry in
            let isLargeScreen = geometry.size.width > 1000
            let spacing: CGFloat = isLargeScreen ? 20 : 14
            let previewHeight: CGFloat = isLargeScreen ? 100 : 85
            let inputHeight: CGFloat = textStyleType == .paragraph ? (isLargeScreen ? 200 : 160) : 0

            // Calculate modal dimensions
            let toolbarWidth: CGFloat = isLargeScreen ? 180 : 140
            let minModalWidth: CGFloat = isLargeScreen ? 840 : 696
            let modalWidth: CGFloat = minModalWidth

            ZStack {
                // Modal content centered in entire screen
                VStack(spacing: spacing) {
                    headerView(isLarge: isLargeScreen)
                    textPreviewView(isLarge: isLargeScreen, height: previewHeight)
                    textInputView(isLarge: isLargeScreen, height: inputHeight)
                    fontPickerView(isLarge: isLargeScreen)
                    colorPickerView(isLarge: isLargeScreen)
                    stylePickerView(isLarge: isLargeScreen)
                    addButtonView(isLarge: isLargeScreen)
                }
                .frame(width: modalWidth)
                .padding(.vertical, isLargeScreen ? 24 : 20)
                .background(Color(white: 0.96))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 4)
                .offset(x: toolbarWidth / 2, y: 0) // Shift right by half toolbar width to account for toolbar on left
            }
            .overlay(colorPickerOverlay)
        }
    }

    // MARK: - View Components
    private func headerView(isLarge: Bool) -> some View {
        HStack {
            Spacer()
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: isLarge ? 32 : 28))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, isLarge ? 30 : 20)
        .padding(.top, 10)
    }

    private func textPreviewView(isLarge: Bool, height: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: isLarge ? 20 : 16)
                .fill(Color.gray.opacity(0.1))
                .frame(height: height)

            if text.isEmpty {
                Text(placeholderText)
                    .font(.system(size: isLarge ? 36 : 28, weight: .bold))
                    .foregroundColor(.gray.opacity(0.5))
            } else {
                styledText
                    .font(selectedFont.font(size: isLarge ? 36 : 28))
            }
        }
        .padding(.horizontal, isLarge ? 30 : 20)
    }

    @ViewBuilder
    private func textInputView(isLarge: Bool, height: CGFloat) -> some View {
        if textStyleType == .paragraph {
                // Multi-line text editor for paragraphs
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text(inputPlaceholder)
                            .font(.system(size: isLarge ? 24 : 20))
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.horizontal, 29)
                            .padding(.vertical, 33)
                    }
                    TextEditor(text: $text)
                        .font(.system(size: isLarge ? 24 : 20))
                        .frame(height: height)
                        .padding(isLarge ? 20 : 15)
                        .scrollContentBackground(.hidden)
                        .background(Color.white)
                        .multilineTextAlignment(textAlignment)
                }
                .background(Color.white)
                .cornerRadius(isLarge ? 16 : 12)
                .overlay(
                    RoundedRectangle(cornerRadius: isLarge ? 16 : 12)
                        .stroke(Color.orange, lineWidth: 2)
                )
                .padding(.horizontal, isLarge ? 30 : 20)

                // Alignment and RTL options for paragraphs
                HStack(spacing: isLarge ? 20 : 15) {
                    Button(action: { textAlignment = .leading }) {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: isLarge ? 24 : 20))
                            .foregroundColor(textAlignment == .leading ? .orange : .gray)
                            .frame(width: isLarge ? 50 : 44, height: isLarge ? 50 : 44)
                            .background(textAlignment == .leading ? Color.orange.opacity(0.1) : Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    Button(action: { textAlignment = .center }) {
                        Image(systemName: "text.aligncenter")
                            .font(.system(size: isLarge ? 24 : 20))
                            .foregroundColor(textAlignment == .center ? .orange : .gray)
                            .frame(width: isLarge ? 50 : 44, height: isLarge ? 50 : 44)
                            .background(textAlignment == .center ? Color.orange.opacity(0.1) : Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    Button(action: { textAlignment = .trailing }) {
                        Image(systemName: "text.alignright")
                            .font(.system(size: isLarge ? 24 : 20))
                            .foregroundColor(textAlignment == .trailing ? .orange : .gray)
                            .frame(width: isLarge ? 50 : 44, height: isLarge ? 50 : 44)
                            .background(textAlignment == .trailing ? Color.orange.opacity(0.1) : Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, isLarge ? 30 : 20)
            } else {
                // Single-line text field for title and caption
                TextField(inputPlaceholder, text: $text)
                    .font(.system(size: isLarge ? 28 : 24))
                    .padding(isLarge ? 25 : 20)
                    .background(Color.white)
                    .cornerRadius(isLarge ? 16 : 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: isLarge ? 16 : 12)
                            .stroke(Color.orange, lineWidth: 2)
                    )
                    .padding(.horizontal, isLarge ? 30 : 20)
            }

    }

    private func fontPickerView(isLarge: Bool) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: isLarge ? 15 : 12) {
                    ForEach(TextFont.allCases, id: \.self) { font in
                        Button(action: {
                            selectedFont = font
                        }) {
                            Text("Aa")
                                .font(font.font(size: isLarge ? 32 : 26))
                                .foregroundColor(selectedFont == font ? .orange : .black)
                                .frame(width: isLarge ? 80 : 65, height: isLarge ? 80 : 65)
                                .background(selectedFont == font ? Color.orange.opacity(0.1) : Color.gray.opacity(0.1))
                                .cornerRadius(12)
                                .overlay(
                                    VStack {
                                        Spacer()
                                        Text(font.rawValue)
                                            .font(.system(size: isLarge ? 10 : 9, weight: .medium))
                                            .foregroundColor(selectedFont == font ? .orange : .gray)
                                            .padding(.bottom, isLarge ? 6 : 4)
                                    }
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedFont == font ? Color.orange : Color.clear, lineWidth: 2)
                                )
                        }
                    }
                }
                .padding(.horizontal, isLarge ? 30 : 20)
            }
            .frame(height: isLarge ? 90 : 75)
    }

    private func colorPickerView(isLarge: Bool) -> some View {
        VStack(alignment: .leading, spacing: isLarge ? 15 : 12) {
                Text("Color")
                    .font(.system(size: isLarge ? 24 : 20, weight: .semibold))
                    .foregroundColor(.gray)

                HStack(spacing: isLarge ? 20 : 15) {
                    ForEach(presetColors, id: \.self) { color in
                        Button(action: {
                            selectedColor = color
                        }) {
                            Circle()
                                .fill(color)
                                .frame(width: isLarge ? 56 : 46, height: isLarge ? 56 : 46)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? Color.orange : Color.clear, lineWidth: isLarge ? 4 : 3)
                                        .frame(width: isLarge ? 66 : 56, height: isLarge ? 66 : 56)
                                )
                                .overlay(
                                    color == .white ? Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1) : nil
                                )
                        }
                    }

                    // Rainbow color picker button
                    Button(action: {
                        showColorPicker = true
                    }) {
                        Circle()
                            .fill(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        .red, .yellow, .green, .cyan, .blue, Color(red: 1, green: 0, blue: 1), .red
                                    ]),
                                    center: .center
                                )
                            )
                            .frame(width: isLarge ? 56 : 46, height: isLarge ? 56 : 46)
                            .overlay(
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: isLarge ? 24 : 20))
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                            )
                    }
                }
            }
            .padding(.horizontal, isLarge ? 30 : 20)
    }

    private func stylePickerView(isLarge: Bool) -> some View {
        VStack(alignment: .leading, spacing: isLarge ? 15 : 12) {
                Text("Style")
                    .font(.system(size: isLarge ? 24 : 20, weight: .semibold))
                    .foregroundColor(.gray)

                HStack(spacing: isLarge ? 20 : 15) {
                    StyleButton(style: .bold, isSelected: selectedStyle == .bold, isLarge: isLarge) {
                        selectedStyle = .bold
                    }
                    StyleButton(style: .outline, isSelected: selectedStyle == .outline, isLarge: isLarge) {
                        selectedStyle = .outline
                    }
                    StyleButton(style: .shadow, isSelected: selectedStyle == .shadow, isLarge: isLarge) {
                        selectedStyle = .shadow
                    }
                }
            }
            .padding(.horizontal, isLarge ? 30 : 20)
    }

    private func addButtonView(isLarge: Bool) -> some View {
        Button(action: {
                if !text.isEmpty {
                    onTextAdded(text, selectedColor, selectedStyle, selectedFont.fontName)
                    isPresented = false
                }
            }) {
                Text("Add Text")
                    .font(.system(size: isLarge ? 20 : 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, isLarge ? 16 : 14)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.4, blue: 0.3),
                                Color(red: 1.0, green: 0.6, blue: 0.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .opacity(text.isEmpty ? 0.4 : 1.0)
            }
            .disabled(text.isEmpty)
            .padding(.horizontal, isLarge ? 24 : 20)
            .padding(.top, isLarge ? 16 : 12)
    }

    @ViewBuilder
    private var colorPickerOverlay: some View {
        if showColorPicker {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                showColorPicker = false
                            }

                        ColorPickerView(isPresented: $showColorPicker) { color in
                            selectedColor = color
                        }
                    }
        }
    }

    @ViewBuilder
    private var styledText: some View {
        switch selectedStyle {
        case .bold:
            Text(text)
                .foregroundColor(selectedColor)
        case .outline:
            ZStack {
                Text(text)
                    .foregroundColor(.clear)
                    .background(
                        Text(text)
                            .foregroundColor(selectedColor)
                            .offset(x: -2, y: -2)
                    )
                    .background(
                        Text(text)
                            .foregroundColor(selectedColor)
                            .offset(x: 2, y: 2)
                    )
                Text(text)
                    .foregroundColor(selectedColor == .white ? .black : .white)
            }
        case .shadow:
            Text(text)
                .foregroundColor(selectedColor)
                .shadow(color: .black.opacity(0.5), radius: 4, x: 2, y: 2)
        }
    }
}

struct StyleButton: View {
    let style: TextOverlayView.TextStyle
    let isSelected: Bool
    let isLarge: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: isLarge ? 8 : 6) {
                Text("Aa")
                    .font(.system(size: isLarge ? 32 : 26, weight: .bold))
                    .modifier(StyleModifier(style: style))

                Text(styleName)
                    .font(.system(size: isLarge ? 18 : 15))
                    .foregroundColor(isSelected ? .orange : .gray)
            }
            .frame(width: isLarge ? 100 : 85, height: isLarge ? 100 : 85)
            .background(isSelected ? Color.orange.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(isLarge ? 16 : 12)
            .overlay(
                RoundedRectangle(cornerRadius: isLarge ? 16 : 12)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: isLarge ? 3 : 2)
            )
        }
    }

    private var styleName: String {
        switch style {
        case .bold: return "Bold"
        case .outline: return "Outline"
        case .shadow: return "Shadow"
        }
    }
}

struct StyleModifier: ViewModifier {
    let style: TextOverlayView.TextStyle

    func body(content: Content) -> some View {
        switch style {
        case .bold:
            content.foregroundColor(.black)
        case .outline:
            ZStack {
                content.foregroundColor(.clear)
                    .background(content.foregroundColor(.black).offset(x: -1, y: -1))
                    .background(content.foregroundColor(.black).offset(x: 1, y: 1))
                content.foregroundColor(.white)
            }
        case .shadow:
            content
                .foregroundColor(.black)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
        }
    }
}
