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
            VStack(alignment: .leading, spacing: 8) {
                Text("To: \(sessionManager.drawingState.recipient)")
                    .font(.system(size: 36, weight: .semibold))
                Text("From: \(sessionManager.drawingState.sender)")
                    .font(.system(size: 28))
                    .foregroundColor(.gray)
            }
            .padding(.leading, 40)

            Spacer()

            Text("Step 3 of 3")
                .font(.system(size: 28))
                .foregroundColor(.gray)
                .padding(.trailing, 40)
        }
        .padding(.vertical, 20)
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
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                    Slider(value: $strokeWidth, in: 1...20, step: 1)
                        .frame(width: 200)
                        .accentColor(Color(red: 1.0, green: 0.5, blue: 0.0))
                }

                Spacer()

                // Undo button
                Button(action: {
                    canvasView.undoManager?.undo()
                    sessionManager.triggerHaptic(.light)
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                            .font(.system(size: 44))
                        Text("Undo")
                            .font(.system(size: 18))
                    }
                    .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.0))
                }
                .disabled(canvasView.undoManager?.canUndo != true)

                // Clear button
                Button(action: {
                    sessionManager.drawingState.drawing = PKDrawing()
                    sessionManager.triggerHaptic(.medium)
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 44))
                        Text("Clear")
                            .font(.system(size: 18))
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
            HStack(spacing: 30) {
                Button(action: {
                    sessionManager.triggerHaptic(.light)
                    sessionManager.currentState = .templateSelection
                }) {
                    Text("Change Template")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 25)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(16)
                }

                Spacer()

                Button(action: {
                    sessionManager.triggerHaptic(.medium)
                    sessionManager.proceedToPreview()
                }) {
                    HStack(spacing: 15) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 36))
                        Text("Preview & Submit")
                            .font(.system(size: 36, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 50)
                    .padding(.vertical, 25)
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
                    .cornerRadius(16)
                    .shadow(color: .orange.opacity(0.4), radius: 15, y: 10)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 30)
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
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                Text(label)
                    .font(.system(size: 18))
            }
            .foregroundColor(isSelected ? Color(red: 1.0, green: 0.5, blue: 0.0) : .gray)
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(isSelected ? Color.orange.opacity(0.1) : Color.clear)
            .cornerRadius(16)
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
                    .frame(width: 56, height: 56)

                if isSelected {
                    Circle()
                        .stroke(Color(red: 1.0, green: 0.5, blue: 0.0), lineWidth: 4)
                        .frame(width: 66, height: 66)
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
        canvasView.delegate = context.coordinator

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

    class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing

        init(drawing: Binding<PKDrawing>) {
            self._drawing = drawing
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing = canvasView.drawing
        }
    }
}

#Preview {
    DrawingCanvasView()
        .environmentObject(SessionManager())
}
