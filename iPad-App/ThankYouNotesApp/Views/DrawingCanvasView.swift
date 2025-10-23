import SwiftUI
import PencilKit

struct DrawingCanvasView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var canvasView = PKCanvasView()
    @State private var selectedTool: DrawingTool = .pen
    @State private var strokeWidth: CGFloat = 3.0
    @State private var selectedColor: Color = .black
    @State private var showColorPicker = false

    enum DrawingTool {
        case pen, eraser
    }

    let presetColors: [Color] = [
        .black, .blue, .red, .green, .orange, .purple, .pink, .brown
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Template background
                Color(hexString: sessionManager.drawingState.template.backgroundColor)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header with names
                    headerView
                        .frame(height: geometry.size.height * 0.1)

                    // Canvas area (70%)
                    PKCanvasViewRepresentable(
                        canvasView: $canvasView,
                        drawing: $sessionManager.drawingState.drawing,
                        selectedTool: selectedTool,
                        strokeWidth: strokeWidth,
                        selectedColor: selectedColor
                    )
                    .frame(height: geometry.size.height * 0.60)
                    .background(Color.white.opacity(0.01))

                    // Toolbar (30%)
                    toolbarView
                        .frame(height: geometry.size.height * 0.30)
                        .background(Color.white)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("To: \(sessionManager.drawingState.recipient)")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("From: \(sessionManager.drawingState.sender)")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 30)

            Spacer()

            Text("Step 3 of 3")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.trailing, 30)
        }
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.95))
    }

    // MARK: - Toolbar View
    private var toolbarView: some View {
        VStack(spacing: 20) {
            Divider()

            // Tool selection and undo
            HStack(spacing: 30) {
                // Pen tool
                ToolButton(
                    icon: "pencil.tip",
                    label: "Pen",
                    isSelected: selectedTool == .pen
                ) {
                    selectedTool = .pen
                    sessionManager.triggerHaptic(.light)
                }

                // Eraser tool
                ToolButton(
                    icon: "eraser.fill",
                    label: "Eraser",
                    isSelected: selectedTool == .eraser
                ) {
                    selectedTool = .eraser
                    sessionManager.triggerHaptic(.light)
                }

                Spacer()

                // Stroke width slider
                VStack(spacing: 8) {
                    Text("Width")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Slider(value: $strokeWidth, in: 1...20, step: 1)
                        .frame(width: 150)
                        .accentColor(.blue)
                }

                Spacer()

                // Undo button
                Button(action: {
                    canvasView.undoManager?.undo()
                    sessionManager.triggerHaptic(.light)
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                            .font(.system(size: 32))
                        Text("Undo")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
                .disabled(canvasView.undoManager?.canUndo != true)

                // Clear button
                Button(action: {
                    sessionManager.drawingState.drawing = PKDrawing()
                    sessionManager.triggerHaptic(.medium)
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 32))
                        Text("Clear")
                            .font(.caption)
                    }
                    .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 30)

            // Color picker
            HStack(spacing: 15) {
                ForEach(presetColors, id: \.self) { color in
                    ColorButton(
                        color: color,
                        isSelected: selectedColor == color
                    ) {
                        selectedColor = color
                        sessionManager.triggerHaptic(.light)
                    }
                }

                Spacer()

                // Custom color picker button
                Button(action: {
                    showColorPicker.toggle()
                    sessionManager.triggerHaptic(.light)
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.red, .yellow, .green, .blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 44, height: 44)

                        Image(systemName: "eyedropper")
                            .foregroundColor(.white)
                            .font(.title3)
                    }
                }
                .sheet(isPresented: $showColorPicker) {
                    ColorPicker("Select Color", selection: $selectedColor)
                        .padding()
                        .presentationDetents([.medium])
                }
            }
            .padding(.horizontal, 30)

            // Action buttons
            HStack(spacing: 20) {
                Button(action: {
                    sessionManager.triggerHaptic(.light)
                    sessionManager.currentState = .templateSelection
                }) {
                    Text("Change Template")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                }

                Spacer()

                Button(action: {
                    sessionManager.triggerHaptic(.medium)
                    sessionManager.proceedToPreview()
                }) {
                    HStack {
                        Image(systemName: "eye.fill")
                        Text("Preview & Submit")
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Tool Button
struct ToolButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .blue : .gray)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(12)
        }
    }
}

// MARK: - Color Button
struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 44, height: 44)

                if isSelected {
                    Circle()
                        .stroke(Color.blue, lineWidth: 3)
                        .frame(width: 50, height: 50)
                }
            }
        }
    }
}

// MARK: - PKCanvasView Representable
struct PKCanvasViewRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var drawing: PKDrawing
    let selectedTool: DrawingCanvasView.DrawingTool
    let strokeWidth: CGFloat
    let selectedColor: Color

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawing = drawing
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput

        // Set initial tool
        updateTool()

        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update drawing if changed externally
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }

        // Update tool
        updateTool()
    }

    private func updateTool() {
        switch selectedTool {
        case .pen:
            let ink = PKInkingTool(
                .pen,
                color: UIColor(selectedColor),
                width: strokeWidth
            )
            canvasView.tool = ink
        case .eraser:
            canvasView.tool = PKEraserTool(.vector)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing)
    }

    class Coordinator: NSObject {
        @Binding var drawing: PKDrawing

        init(drawing: Binding<PKDrawing>) {
            self._drawing = drawing
        }
    }
}

#Preview {
    DrawingCanvasView()
        .environmentObject(SessionManager())
}
