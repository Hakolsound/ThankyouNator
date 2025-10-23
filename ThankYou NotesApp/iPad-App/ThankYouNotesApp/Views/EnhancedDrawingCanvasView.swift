import SwiftUI
import PencilKit
import FirebaseDatabase

struct EnhancedDrawingCanvasView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var canvasView = PKCanvasView()
    @State private var selectedTool: DrawingTool = .pen
    @State private var selectedInkType: PKInkingTool.InkType = .pen
    @State private var strokeWidth: CGFloat = 3.0
    @State private var selectedColor: Color = .black
    @State private var showColorPicker = false
    @State private var showEmojiPicker = false
    @State private var showTextOverlay = false
    @State private var showQRCode = false
    @State private var showPencilToolPicker = false
    @State private var showTextStylePicker = false
    @State private var selectedTextStyle: TextStyleType = .title
    @State private var selectedOverlayId: UUID?
    @State private var dragOffset: CGSize = .zero
    @State private var photoListenerHandle: DatabaseHandle?
    @State private var firebaseService = FirebaseService()
    @State private var isLoadingPhoto = false

    // Canvas rendering size (matches preview rendering size)
    static let canvasRenderSize = CGSize(width: 1200, height: 1600)

    enum DrawingTool {
        case pen, eraser
    }

    let presetColors: [Color] = [
        .black, .blue, .red, .green, .orange, .purple, .pink, .brown
    ]

    var body: some View {
        GeometryReader { geometry in
            // Calculate dynamic sizes based on screen
            let isLargeScreen = geometry.size.width > 1000
            let toolbarWidth: CGFloat = isLargeScreen ? 180 : 140
            let headerHeight: CGFloat = isLargeScreen ? 80 : 60
            let bottomPadding: CGFloat = isLargeScreen ? 80 : 60

            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.92, blue: 0.98),
                        Color(red: 0.98, green: 0.95, blue: 0.99)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                HStack(spacing: 0) {
                    // Left side toolbar
                    VStack(spacing: isLargeScreen ? 20 : 15) {
                        Spacer()
                        toolbarVerticalView(geometry: geometry)
                        Spacer()
                    }
                    .frame(width: toolbarWidth)
                    .background(Color.white.opacity(0.5))

                    // Main canvas area
                    VStack(spacing: 0) {
                        // Compact header (To: only)
                        compactHeaderView(geometry: geometry)
                            .frame(height: headerHeight)

                        // Centered canvas with card appearance
                        GeometryReader { canvasGeometry in
                            let targetAspectRatio: CGFloat = 3.0 / 4.0
                            let availableWidth = canvasGeometry.size.width - 60
                            let availableHeight = canvasGeometry.size.height - 40
                            let calculatedWidth = min(availableWidth, availableHeight * targetAspectRatio)
                            let calculatedHeight = calculatedWidth / targetAspectRatio

                            ZStack {
                            // Template background and decorations at the very bottom
                            ZStack {
                                Color(hexString: sessionManager.drawingState.template.backgroundColor)
                                TemplateDecorationsView(template: sessionManager.drawingState.template)
                            }

                            // PKCanvas on top - allows drawing everywhere
                            EnhancedPKCanvasViewRepresentable(
                                canvasView: $canvasView,
                                drawing: $sessionManager.drawingState.drawing,
                                selectedTool: selectedTool,
                                selectedInkType: selectedInkType,
                                strokeWidth: strokeWidth,
                                selectedColor: selectedColor
                            )
                            .background(Color.clear)
                            .allowsHitTesting(selectedOverlayId == nil) // Only draw when no overlay selected

                            // ALL overlays on top of drawing - interactive
                            ForEach(sessionManager.drawingState.overlays) { overlay in
                                OverlayView(
                                    overlay: overlay,
                                    canvasSize: CGSize(width: calculatedWidth, height: calculatedHeight),
                                    renderSize: Self.canvasRenderSize,
                                    isSelected: selectedOverlayId == overlay.id,
                                    onTap: {
                                        selectedOverlayId = overlay.id
                                    },
                                    onDelete: {
                                        deleteOverlay(overlay.id)
                                    },
                                    onPositionChange: { newPosition in
                                        updateOverlayPosition(overlay.id, newPosition: newPosition, canvasSize: CGSize(width: calculatedWidth, height: calculatedHeight))
                                    },
                                    onScaleChange: { newScale in
                                        updateOverlayScale(overlay.id, newScale: newScale)
                                    },
                                    onRotationChange: { newRotation in
                                        updateOverlayRotation(overlay.id, newRotation: newRotation)
                                    }
                                )
                                .zIndex(overlay.id == selectedOverlayId ? 1000 : Double(sessionManager.drawingState.overlays.firstIndex(where: { $0.id == overlay.id }) ?? 0))
                            }

                            // Loading indicator when photo is being uploaded
                            if isLoadingPhoto {
                                VStack(spacing: 20) {
                                    ProgressView()
                                        .scaleEffect(2.0)
                                        .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                                    Text("Loading photo...")
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(.orange)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.white.opacity(0.9))
                            }
                            }
                            .frame(width: calculatedWidth, height: calculatedHeight)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // Deselect overlay when tapping empty space
                                selectedOverlayId = nil
                            }
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.5),
                                                Color.gray.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .padding(.bottom, bottomPadding)

                        // Footer with From field
                        compactFooterView(geometry: geometry)
                            .frame(height: headerHeight)
                    }
                }

                // Modal overlays
                if showEmojiPicker {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showEmojiPicker = false
                        }

                    VStack {
                        Spacer()
                        EmojiPickerView(isPresented: $showEmojiPicker) { emoji in
                            addEmojiOverlay(emoji)
                        }
                        .frame(height: geometry.size.height * 0.7)
                    }
                    .transition(.move(edge: .bottom))
                }

                if showTextOverlay {
                    HStack(spacing: 0) {
                        // Keep toolbar area clear
                        Color.clear
                            .frame(width: geometry.size.width > 1000 ? 180 : 140)

                        // Dark overlay on the rest
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                showTextOverlay = false
                            }
                    }

                    HStack(spacing: 0) {
                        // Keep toolbar area clear
                        Color.clear
                            .frame(width: geometry.size.width > 1000 ? 180 : 140)

                        VStack {
                            Spacer()
                            TextOverlayView(
                                isPresented: $showTextOverlay,
                                textStyleType: selectedTextStyle
                            ) { text, color, style, fontName in
                                addTextOverlay(text, color: color, style: style, fontName: fontName)
                            }
                            .frame(height: geometry.size.height * 0.85)
                        }
                    }
                    .transition(.move(edge: .bottom))
                }

                if showQRCode {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showQRCode = false
                        }

                    QRCodeView(
                        isPresented: $showQRCode,
                        sessionId: sessionManager.drawingState.sessionId,
                        uploadURL: getPhotoUploadURL()
                    )
                    .frame(width: 600, height: 800)
                    .transition(.scale.combined(with: .opacity))
                }

                if showColorPicker {
                    ColorPickerView(isPresented: $showColorPicker) { color in
                        selectedColor = color
                    }
                    .transition(.scale(scale: 0.1, anchor: .bottomLeading).combined(with: .opacity))
                }

                if showPencilToolPicker {
                    PencilToolPickerView(isPresented: $showPencilToolPicker) { inkType, name in
                        selectedInkType = inkType
                        selectedTool = .pen
                    }
                    .transition(.scale(scale: 0.1, anchor: .topLeading).combined(with: .opacity))
                }

                if showTextStylePicker {
                    TextStylePickerView(isPresented: $showTextStylePicker) { style in
                        selectedTextStyle = style
                        showTextOverlay = true
                        showTextStylePicker = false
                    }
                    .transition(.scale(scale: 0.1, anchor: .topLeading).combined(with: .opacity))
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.spring(response: 0.3), value: showEmojiPicker)
        .animation(.spring(response: 0.3), value: showTextOverlay)
        .animation(.spring(response: 0.3), value: showQRCode)
        .animation(.spring(response: 0.3), value: showColorPicker)
        .animation(.spring(response: 0.3), value: showPencilToolPicker)
        .animation(.spring(response: 0.3), value: showTextStylePicker)
        .onAppear {
            startListeningForPhotoUploads()
        }
        .onDisappear {
            stopListeningForPhotoUploads()
        }
    }

    // MARK: - Compact Header View
    private func compactHeaderView(geometry: GeometryProxy) -> some View {
        let fontSize: CGFloat = geometry.size.width > 1000 ? 24 : 18

        return HStack {
            HStack(spacing: 8) {
                Text("To:")
                    .font(.system(size: fontSize, weight: .semibold))
                    .foregroundColor(.gray)
                Text(sessionManager.drawingState.recipient)
                    .font(.system(size: fontSize, weight: .bold))
                    .foregroundColor(.purple)
            }

            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 15)
        .background(Color.white.opacity(0.7))
    }

    private func compactFooterView(geometry: GeometryProxy) -> some View {
        let fontSize: CGFloat = geometry.size.width > 1000 ? 24 : 18

        return HStack {
            Spacer()

            HStack(spacing: 8) {
                Text("From:")
                    .font(.system(size: fontSize, weight: .semibold))
                    .foregroundColor(.gray)
                Text(sessionManager.drawingState.sender)
                    .font(.system(size: fontSize, weight: .bold))
                    .foregroundColor(.purple)
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 15)
        .background(Color.white.opacity(0.7))
    }

    // MARK: - Vertical Toolbar View
    private func toolbarVerticalView(geometry: GeometryProxy) -> some View {
        let isLarge = geometry.size.width > 1000
        let buttonSize: CGFloat = isLarge ? 70 : 55
        let iconSize: CGFloat = isLarge ? 32 : 26
        let fontSize: CGFloat = isLarge ? 14 : 11

        return VStack(spacing: isLarge ? 12 : 10) {
            // Drawing tools
            VStack(spacing: 8) {
                // Pen button with tap to toggle tool selector
                VStack(spacing: 4) {
                    Image(systemName: "pencil.tip")
                        .font(.system(size: iconSize))
                    Text("Pen")
                        .font(.system(size: fontSize))
                }
                .foregroundColor(selectedTool == .pen ? .white : Color(red: 0.7, green: 0.3, blue: 0.9))
                .frame(width: buttonSize, height: buttonSize)
                .background(
                    Group {
                        if selectedTool == .pen {
                            LinearGradient(
                                colors: [
                                    Color(red: 0.6, green: 0.3, blue: 1.0),
                                    Color(red: 0.8, green: 0.3, blue: 0.9)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        } else {
                            Color.clear
                        }
                    }
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.7, green: 0.3, blue: 0.9), lineWidth: selectedTool == .pen ? 0 : 1)
                )
                .onTapGesture {
                    // If pen is already selected, toggle tool picker
                    if selectedTool == .pen {
                        showPencilToolPicker.toggle()
                        sessionManager.triggerHaptic(.medium)
                    } else {
                        // Otherwise, select pen tool and close picker
                        selectedTool = .pen
                        showPencilToolPicker = false
                        sessionManager.triggerHaptic(.light)
                    }
                }

                ToolButtonVertical(
                    icon: "eraser.fill",
                    label: "Erase",
                    isSelected: selectedTool == .eraser,
                    size: buttonSize,
                    iconSize: iconSize,
                    fontSize: fontSize
                ) {
                    selectedTool = .eraser
                    showPencilToolPicker = false // Close tool picker when switching away
                    showTextStylePicker = false
                    sessionManager.triggerHaptic(.light)
                }
            }

            Divider().padding(.vertical, 4)

            // Creative tools
            VStack(spacing: 8) {
                Button(action: {
                    showEmojiPicker = true
                    showPencilToolPicker = false // Close tool picker
                    showTextStylePicker = false
                    sessionManager.triggerHaptic(.medium)
                }) {
                    VStack(spacing: 4) {
                        Text("😀").font(.system(size: iconSize))
                        Text("Emoji").font(.system(size: fontSize))
                            .foregroundColor(Color(red: 0.8, green: 0.3, blue: 0.9))
                    }
                    .frame(width: buttonSize, height: buttonSize)
                    .background(Color(red: 0.8, green: 0.3, blue: 0.9).opacity(0.1))
                    .cornerRadius(12)
                }

                VStack(spacing: 4) {
                    Image(systemName: "textformat.size").font(.system(size: iconSize))
                    Text("Text").font(.system(size: fontSize))
                }
                .foregroundColor(Color(red: 0.8, green: 0.3, blue: 0.9))
                .frame(width: buttonSize, height: buttonSize)
                .background(Color(red: 0.8, green: 0.3, blue: 0.9).opacity(0.1))
                .cornerRadius(12)
                .onTapGesture {
                    // Always toggle the style picker on text button press
                    showTextStylePicker.toggle()
                    showPencilToolPicker = false
                    sessionManager.triggerHaptic(.medium)
                }

                Button(action: {
                    showQRCode = true
                    showPencilToolPicker = false // Close tool picker
                    showTextStylePicker = false
                    sessionManager.triggerHaptic(.medium)
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "qrcode").font(.system(size: iconSize))
                        Text("Photo").font(.system(size: fontSize))
                    }
                    .foregroundColor(Color(red: 0.8, green: 0.3, blue: 0.9))
                    .frame(width: buttonSize, height: buttonSize)
                    .background(Color(red: 0.8, green: 0.3, blue: 0.9).opacity(0.1))
                    .cornerRadius(12)
                }
            }

            Divider().padding(.vertical, 4)

            // Color palette - vertical
            VStack(spacing: 6) {
                ForEach(presetColors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: isLarge ? 36 : 30, height: isLarge ? 36 : 30)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                        )
                        .shadow(radius: selectedColor == color ? 3 : 0)
                        .onTapGesture {
                            selectedColor = color
                            sessionManager.triggerHaptic(.light)
                        }
                }

                // Custom color picker button
                Circle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                .red, .yellow, .green, .cyan, .blue, Color(red: 1, green: 0, blue: 1), .red
                            ]),
                            center: .center
                        )
                    )
                    .frame(width: isLarge ? 36 : 30, height: isLarge ? 36 : 30)
                    .overlay(
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: isLarge ? 20 : 16))
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                    )
                    .shadow(radius: 3)
                    .onTapGesture {
                        showColorPicker = true
                        sessionManager.triggerHaptic(.light)
                    }
            }

            Divider().padding(.vertical, 4)

            // Width slider - vertical
            VStack(spacing: 8) {
                Text("Width")
                    .font(.system(size: fontSize))
                    .foregroundColor(.gray)

                VStack {
                    Text("\(Int(strokeWidth))")
                        .font(.system(size: fontSize, weight: .bold))
                        .foregroundColor(Color(red: 0.7, green: 0.3, blue: 0.9))

                    Slider(value: $strokeWidth, in: 1...20, step: 1)
                        .rotationEffect(.degrees(-90))
                        .frame(width: 80, height: isLarge ? 100 : 80)
                        .accentColor(Color(red: 0.7, green: 0.3, blue: 0.9))
                }
            }

            Divider().padding(.vertical, 4)

            // Action buttons
            VStack(spacing: 8) {
                Button(action: {
                    canvasView.undoManager?.undo()
                    sessionManager.triggerHaptic(.light)
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                            .font(.system(size: iconSize))
                        Text("Undo").font(.system(size: fontSize))
                    }
                    .foregroundColor(Color(red: 0.7, green: 0.3, blue: 0.9))
                    .frame(width: buttonSize, height: buttonSize)
                }
                .disabled(canvasView.undoManager?.canUndo != true)

                Button(action: {
                    sessionManager.drawingState.drawing = PKDrawing()
                    sessionManager.drawingState.overlays = []
                    sessionManager.triggerHaptic(.medium)
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: iconSize))
                        Text("Clear").font(.system(size: fontSize))
                    }
                    .foregroundColor(.red)
                    .frame(width: buttonSize, height: buttonSize)
                }

                Button(action: {
                    sessionManager.triggerHaptic(.light)
                    sessionManager.currentState = .templateSelection
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.system(size: iconSize))
                        Text("Theme").font(.system(size: fontSize))
                    }
                    .foregroundColor(Color(red: 0.7, green: 0.3, blue: 0.9))
                    .frame(width: buttonSize, height: buttonSize)
                }
            }

            Divider().padding(.vertical, 4)

            // Preview button
            Button(action: {
                sessionManager.triggerHaptic(.medium)
                sessionManager.proceedToPreview()
            }) {
                VStack(spacing: 6) {
                    Image(systemName: "eye.fill")
                        .font(.system(size: iconSize + 4))
                    Text("Preview")
                        .font(.system(size: fontSize, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(width: buttonSize + 20, height: buttonSize + 20)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.5, green: 0.3, blue: 1.0),
                            Color(red: 0.8, green: 0.3, blue: 0.9),
                            Color(red: 1.0, green: 0.3, blue: 0.7)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color(red: 0.8, green: 0.3, blue: 0.9).opacity(0.4), radius: 8, y: 4)
            }
        }
        .padding(.vertical, 20)
    }

    // MARK: - Old Toolbar View (keeping for reference, will be removed)
    private var toolbarView: some View {
        VStack(spacing: 15) {
            Divider()

            // Enhanced tool selection
            HStack(spacing: 20) {
                // Drawing tools
                ToolButton(icon: "pencil.tip", label: "Pen", isSelected: selectedTool == .pen) {
                    selectedTool = .pen
                    sessionManager.triggerHaptic(.light)
                }

                ToolButton(icon: "eraser.fill", label: "Eraser", isSelected: selectedTool == .eraser) {
                    selectedTool = .eraser
                    sessionManager.triggerHaptic(.light)
                }

                Divider()
                    .frame(height: 60)

                // Creative tools
                Button(action: {
                    showEmojiPicker = true
                    sessionManager.triggerHaptic(.medium)
                }) {
                    VStack(spacing: 8) {
                        Text("😀")
                            .font(.system(size: 36))
                        Text("Emoji")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 0.8, green: 0.3, blue: 0.9))
                    }
                    .frame(width: 90, height: 80)
                    .background(Color(red: 0.8, green: 0.3, blue: 0.9).opacity(0.15))
                    .cornerRadius(16)
                }

                Button(action: {
                    showTextOverlay = true
                    sessionManager.triggerHaptic(.medium)
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "textformat.size")
                            .font(.system(size: 36))
                        Text("Text")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(Color(red: 0.8, green: 0.3, blue: 0.9))
                    .frame(width: 90, height: 80)
                    .background(Color(red: 0.8, green: 0.3, blue: 0.9).opacity(0.15))
                    .cornerRadius(16)
                }

                Button(action: {
                    showQRCode = true
                    sessionManager.triggerHaptic(.medium)
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "qrcode")
                            .font(.system(size: 36))
                        Text("Photo")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(Color(red: 0.8, green: 0.3, blue: 0.9))
                    .frame(width: 90, height: 80)
                    .background(Color(red: 0.8, green: 0.3, blue: 0.9).opacity(0.15))
                    .cornerRadius(16)
                }

                Spacer()

                // Stroke width
                VStack(spacing: 8) {
                    Text("Width")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                    Slider(value: $strokeWidth, in: 1...20, step: 1)
                        .frame(width: 180)
                        .accentColor(Color(red: 0.7, green: 0.3, blue: 0.9))
                }

                // Undo & Clear
                Button(action: {
                    canvasView.undoManager?.undo()
                    sessionManager.triggerHaptic(.light)
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                            .font(.system(size: 40))
                        Text("Undo")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(Color(red: 0.7, green: 0.3, blue: 0.9))
                }
                .disabled(canvasView.undoManager?.canUndo != true)

                Button(action: {
                    sessionManager.drawingState.drawing = PKDrawing()
                    sessionManager.drawingState.overlays = []
                    sessionManager.triggerHaptic(.medium)
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 40))
                        Text("Clear")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 30)

            // Color picker
            HStack(spacing: 15) {
                ForEach(presetColors, id: \.self) { color in
                    ColorButton(color: color, isSelected: selectedColor == color) {
                        selectedColor = color
                        sessionManager.triggerHaptic(.light)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 30)

            // Action buttons
            HStack(spacing: 30) {
                Button(action: {
                    sessionManager.triggerHaptic(.light)
                    sessionManager.currentState = .templateSelection
                }) {
                    Text("Change Template")
                        .font(.system(size: 28))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 35)
                        .padding(.vertical, 20)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(16)
                }

                Spacer()

                Button(action: {
                    sessionManager.triggerHaptic(.medium)
                    sessionManager.proceedToPreview()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 32))
                        Text("Preview")
                            .font(.system(size: 32, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 45)
                    .padding(.vertical, 20)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.5, green: 0.3, blue: 1.0),
                                Color(red: 0.8, green: 0.3, blue: 0.9),
                                Color(red: 1.0, green: 0.3, blue: 0.7)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color(red: 0.8, green: 0.3, blue: 0.9).opacity(0.5), radius: 15, y: 10)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Helper Methods
    private func addEmojiOverlay(_ emoji: String) {
        let overlay = CanvasOverlay(
            type: .emoji,
            position: CGPoint(
                x: Self.canvasRenderSize.width / 2,
                y: Self.canvasRenderSize.height / 2
            ),
            scale: 2.0,
            content: emoji
        )
        sessionManager.drawingState.overlays.append(overlay)
    }

    private func addTextOverlay(_ text: String, color: Color, style: TextOverlayView.TextStyle, fontName: String) {
        let hexColor = color.toHex()

        // Different font sizes based on text style type
        let fontSize: CGFloat = {
            switch selectedTextStyle {
            case .title: return 72      // Large, prominent
            case .paragraph: return 36  // Medium, readable
            case .caption: return 24    // Small, subtle
            }
        }()

        let overlay = CanvasOverlay(
            type: .text,
            position: CGPoint(
                x: Self.canvasRenderSize.width / 2,
                y: Self.canvasRenderSize.height / 2
            ),
            scale: 1.0,
            content: text,
            textColor: hexColor,
            fontSize: fontSize,
            fontName: fontName
        )
        sessionManager.drawingState.overlays.append(overlay)
    }

    private func deleteOverlay(_ id: UUID) {
        sessionManager.drawingState.overlays.removeAll { $0.id == id }
        selectedOverlayId = nil
    }

    private func updateOverlayPosition(_ id: UUID, newPosition: CGPoint, canvasSize: CGSize) {
        guard let index = sessionManager.drawingState.overlays.firstIndex(where: { $0.id == id }) else { return }

        // Convert from canvas coordinate space to render coordinate space
        let scaleX = Self.canvasRenderSize.width / canvasSize.width
        let scaleY = Self.canvasRenderSize.height / canvasSize.height

        let renderPosition = CGPoint(
            x: newPosition.x * scaleX,
            y: newPosition.y * scaleY
        )

        sessionManager.drawingState.overlays[index].position = renderPosition
    }

    private func updateOverlayScale(_ id: UUID, newScale: CGFloat) {
        guard let index = sessionManager.drawingState.overlays.firstIndex(where: { $0.id == id }) else { return }
        sessionManager.drawingState.overlays[index].scale = newScale
    }

    private func updateOverlayRotation(_ id: UUID, newRotation: Double) {
        guard let index = sessionManager.drawingState.overlays.firstIndex(where: { $0.id == id }) else { return }
        sessionManager.drawingState.overlays[index].rotation = newRotation
    }

    private func getPhotoUploadURL() -> String {
        // Cloud photo upload web app
        let baseURL = "https://thankyounotes-upload.web.app"
        return "\(baseURL)/upload/\(sessionManager.drawingState.sessionId)"
    }

    private func startListeningForPhotoUploads() {
        let sessionId = sessionManager.drawingState.sessionId
        photoListenerHandle = firebaseService.listenForPhotoUpload(sessionId: sessionId) { [self] base64Image in
            guard let imageData = base64Image else { return }

            // Show loading state and hide QR code
            DispatchQueue.main.async {
                self.isLoadingPhoto = true
                self.showQRCode = false
                self.selectedOverlayId = nil
            }

            // Add photo overlay after a brief delay to show loading animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.addPhotoOverlay(imageData)
                self.isLoadingPhoto = false
                sessionManager.triggerHaptic(.medium)
            }
        }
    }

    private func stopListeningForPhotoUploads() {
        guard let handle = photoListenerHandle else { return }
        let sessionId = sessionManager.drawingState.sessionId
        firebaseService.removePhotoListener(sessionId: sessionId, handle: handle)
        photoListenerHandle = nil
    }

    private func addPhotoOverlay(_ base64Image: String) {
        // Decode image to get original dimensions
        var imageSize: CGSize = CGSize(width: 200, height: 200) // Default
        if let imageData = Data(base64Encoded: base64Image),
           let uiImage = UIImage(data: imageData) {
            imageSize = uiImage.size
        }

        let overlay = CanvasOverlay(
            type: .photo,
            position: CGPoint(
                x: Self.canvasRenderSize.width / 2,
                y: Self.canvasRenderSize.height / 2
            ),
            scale: 1.0,
            content: base64Image,
            imageSize: imageSize
        )
        sessionManager.drawingState.overlays.append(overlay)
    }
}

// MARK: - Overlay View
struct OverlayView: View {
    let overlay: CanvasOverlay
    let canvasSize: CGSize
    let renderSize: CGSize
    let isSelected: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    let onPositionChange: (CGPoint) -> Void
    let onScaleChange: ((CGFloat) -> Void)?
    let onRotationChange: ((Double) -> Void)?

    @State private var position: CGPoint
    @State private var scale: CGFloat
    @State private var rotation: Double

    init(overlay: CanvasOverlay, canvasSize: CGSize, renderSize: CGSize, isSelected: Bool, onTap: @escaping () -> Void, onDelete: @escaping () -> Void, onPositionChange: @escaping (CGPoint) -> Void, onScaleChange: ((CGFloat) -> Void)? = nil, onRotationChange: ((Double) -> Void)? = nil) {
        self.overlay = overlay
        self.canvasSize = canvasSize
        self.renderSize = renderSize
        self.isSelected = isSelected
        self.onTap = onTap
        self.onDelete = onDelete
        self.onPositionChange = onPositionChange
        self.onScaleChange = onScaleChange
        self.onRotationChange = onRotationChange

        // Convert from render coordinate space to canvas coordinate space
        let scaleX = canvasSize.width / renderSize.width
        let scaleY = canvasSize.height / renderSize.height
        let canvasPosition = CGPoint(
            x: overlay.position.x * scaleX,
            y: overlay.position.y * scaleY
        )

        _position = State(initialValue: canvasPosition)
        _scale = State(initialValue: overlay.scale)
        _rotation = State(initialValue: overlay.rotation)
    }

    var body: some View {
        // Calculate scaled sizes based on canvas vs render coordinate space
        let sizeScale = canvasSize.width / renderSize.width
        let scaledEmojiSize = 60.0 * sizeScale
        let scaledFontSize = (overlay.fontSize ?? 48) * sizeScale

        // For photos, calculate actual scaled dimensions
        let scaledPhotoSize: CGSize = {
            if overlay.type == .photo {
                if let storedSize = overlay.imageSize {
                    // Scale to fit within 200x200 while maintaining aspect ratio
                    let maxDimension: CGFloat = 200 * sizeScale
                    let scale = min(maxDimension / (storedSize.width * sizeScale), maxDimension / (storedSize.height * sizeScale))
                    return CGSize(width: storedSize.width * sizeScale * scale, height: storedSize.height * sizeScale * scale)
                } else {
                    // Fallback to square
                    return CGSize(width: 200 * sizeScale, height: 200 * sizeScale)
                }
            }
            return .zero
        }()

        ZStack {
            // Content layer (scaled and rotated)
            Group {
                switch overlay.type {
                case .emoji:
                    Text(overlay.content)
                        .font(.system(size: scaledEmojiSize))

                case .text:
                    let textFont: Font = {
                        if let fontName = overlay.fontName {
                            // Map font names to actual fonts
                            switch fontName {
                            case "System":
                                return .system(size: scaledFontSize, weight: .bold, design: .default)
                            case "Avenir Next Rounded":
                                return .custom("Avenir Next Rounded", size: scaledFontSize)
                            case "Georgia":
                                return .custom("Georgia", size: scaledFontSize)
                            case "Courier":
                                return .custom("Courier", size: scaledFontSize)
                            case "Bradley Hand":
                                return .custom("Bradley Hand", size: scaledFontSize)
                            case "Futura":
                                return .custom("Futura", size: scaledFontSize)
                            case "Avenir Next Bold":
                                return .custom("Avenir Next Bold", size: scaledFontSize)
                            case "Snell Roundhand":
                                return .custom("Snell Roundhand", size: scaledFontSize)
                            default:
                                return .system(size: scaledFontSize, weight: .bold)
                            }
                        } else {
                            return .system(size: scaledFontSize, weight: .bold)
                        }
                    }()

                    // Set max width based on font size for consistent wrapping
                    let maxWidth: CGFloat = {
                        let baseFontSize = overlay.fontSize ?? 48
                        return baseFontSize <= 30 ? 800 * sizeScale : 600 * sizeScale
                    }()

                    Text(overlay.content)
                        .font(textFont)
                        .foregroundColor(Color(hexString: overlay.textColor ?? "#FFFFFF"))
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: maxWidth)

                case .photo:
                    if let imageData = Data(base64Encoded: overlay.content),
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: scaledPhotoSize.width, height: scaledPhotoSize.height)
                            .cornerRadius(12 * sizeScale)
                    }
                }
            }
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .position(position)

            // Delete button - fixed size, positioned at top-right of scaled content
            if isSelected {
                let contentWidth: CGFloat = {
                    switch overlay.type {
                    case .emoji: return scaledEmojiSize * scale
                    case .text: return scaledFontSize * CGFloat(overlay.content.count) * 0.6 * scale
                    case .photo: return scaledPhotoSize.width * scale
                    }
                }()
                let contentHeight: CGFloat = {
                    switch overlay.type {
                    case .emoji: return scaledEmojiSize * scale
                    case .text: return scaledFontSize * scale
                    case .photo: return scaledPhotoSize.height * scale
                    }
                }()

                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 44)) // Fixed size for easy tapping
                        .foregroundColor(.red)
                        .background(Circle().fill(Color.white).frame(width: 40, height: 40))
                }
                .position(
                    x: position.x + contentWidth / 2 + 10,
                    y: position.y - contentHeight / 2 - 10
                )
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    position = value.location
                }
                .onEnded { value in
                    position = value.location
                    onPositionChange(position)
                }
        )
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    scale = value * overlay.scale
                }
                .onEnded { value in
                    let newScale = value * overlay.scale
                    scale = newScale
                    onScaleChange?(newScale)
                }
        )
        .gesture(
            RotationGesture()
                .onChanged { value in
                    rotation = value.degrees + overlay.rotation
                }
                .onEnded { value in
                    let newRotation = value.degrees + overlay.rotation
                    rotation = newRotation
                    onRotationChange?(newRotation)
                }
        )
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Enhanced PKCanvasView Representable
struct EnhancedPKCanvasViewRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var drawing: PKDrawing
    let selectedTool: EnhancedDrawingCanvasView.DrawingTool
    let selectedInkType: PKInkingTool.InkType
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
                selectedInkType,
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

// MARK: - Tool Button Vertical Component
struct ToolButtonVertical: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let size: CGFloat
    let iconSize: CGFloat
    let fontSize: CGFloat
    let action: () -> Void

    private var buttonBackground: some View {
        Group {
            if isSelected {
                LinearGradient(
                    colors: [
                        Color(red: 0.6, green: 0.3, blue: 1.0),
                        Color(red: 0.8, green: 0.3, blue: 0.9)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                Color.clear
            }
        }
    }

    private var buttonForegroundColor: Color {
        isSelected ? .white : Color(red: 0.7, green: 0.3, blue: 0.9)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: iconSize))
                Text(label)
                    .font(.system(size: fontSize))
            }
            .foregroundColor(buttonForegroundColor)
            .frame(width: size, height: size)
            .background(buttonBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.7, green: 0.3, blue: 0.9), lineWidth: isSelected ? 0 : 1)
            )
        }
    }
}

// MARK: - Template Decorations View
struct TemplateDecorationsView: View {
    let template: TemplateTheme

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Use ZStack for gradient effects that Canvas can't do well
                gradientDecorations(size: geometry.size)

                // Use Canvas for shapes and patterns
                Canvas { context, size in
                    drawDecorations(context: context, size: size)
                }
            }
        }
        .allowsHitTesting(false) // Don't intercept touches
    }

    @ViewBuilder
    private func gradientDecorations(size: CGSize) -> some View {
        switch template {
        case .moody:
            // Soft purple glow with radial gradient
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.purple.opacity(0.5),
                            Color.purple.opacity(0.3),
                            Color.purple.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .position(x: size.width / 2, y: size.height / 2)
                .blur(radius: 40)

        case .neonGlow:
            // Cyan glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.cyan.opacity(0.6), Color.cyan.opacity(0.2), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .position(x: size.width * 0.25, y: size.height * 0.3)
                .blur(radius: 20)

            // Pink glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.pink.opacity(0.6), Color.pink.opacity(0.2), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 120
                    )
                )
                .frame(width: 280, height: 280)
                .position(x: size.width * 0.75, y: size.height * 0.65)
                .blur(radius: 25)

        case .galaxy:
            // Purple cloud
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.purple.opacity(0.4), Color.purple.opacity(0.2), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .position(x: size.width * 0.3, y: size.height * 0.35)
                .blur(radius: 30)

            // Blue cloud
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.15), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .position(x: size.width * 0.6, y: size.height * 0.55)
                .blur(radius: 25)

            // Pink cloud
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.pink.opacity(0.25), Color.pink.opacity(0.1), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .position(x: size.width * 0.5, y: size.height * 0.7)
                .blur(radius: 20)

        case .sunset:
            // Gradient bands with soft edges
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [Color.orange.opacity(0.5), Color.orange.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: size.height / 3)

                LinearGradient(
                    colors: [Color.orange.opacity(0.3), Color.pink.opacity(0.35), Color.pink.opacity(0.25)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: size.height / 3)

                LinearGradient(
                    colors: [Color.pink.opacity(0.25), Color.purple.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: size.height / 3)
            }

        case .watercolor:
            // Blue watercolor blob
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.1), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .position(x: size.width * 0.25, y: size.height * 0.25)
                .blur(radius: 15)

            // Purple watercolor blob
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.purple.opacity(0.15), Color.purple.opacity(0.08), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .position(x: size.width * 0.75, y: size.height * 0.75)
                .blur(radius: 12)

        case .gradient:
            // Light gradient from purple to pink
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.3),
                    Color.pink.opacity(0.25),
                    Color.orange.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .darkGradient:
            // Dark gradient from deep purple to black
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.4),
                    Color.purple.opacity(0.2),
                    Color.black.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .floral:
            // Soft peachy gradient overlay
            RadialGradient(
                colors: [Color.clear, Color.orange.opacity(0.1), Color.orange.opacity(0.05)],
                center: .center,
                startRadius: 100,
                endRadius: 300
            )

        default:
            EmptyView()
        }
    }

    private func drawDecorations(context: GraphicsContext, size: CGSize) {
        // Scale factor for consistent rendering
        let scaleX = size.width / 1200
        let scaleY = size.height / 1600

        switch template {
        case .pastelRainbow:
            // Rainbow vertical stripes
            let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
            let stripeWidth = size.width / CGFloat(colors.count)
            for (index, color) in colors.enumerated() {
                let rect = CGRect(x: CGFloat(index) * stripeWidth, y: 0, width: stripeWidth, height: size.height)
                context.fill(Path(rect), with: .color(color.opacity(0.2)))
            }

        case .confetti, .darkConfetti:
            // Random confetti dots
            let dotColors: [Color] = template == .confetti ?
                [.red, .blue, .yellow, .green, .pink] :
                [.cyan, .pink, .yellow, .green]
            for _ in 0..<30 {
                if let color = dotColors.randomElement() {
                    let x = CGFloat.random(in: 50*scaleX...(size.width-50*scaleX))
                    let y = CGFloat.random(in: 50*scaleY...(size.height-50*scaleY))
                    let circle = Circle().path(in: CGRect(x: x, y: y, width: 15*scaleX, height: 15*scaleY))
                    context.fill(circle, with: .color(color))
                }
            }

        case .midnight, .deepSpace, .nightSky:
            // Stars
            for _ in 0..<20 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let starSize = template == .nightSky ? 6*scaleX : 4*scaleX
                let circle = Circle().path(in: CGRect(x: x, y: y, width: starSize, height: starSize))
                context.fill(circle, with: .color(.white.opacity(0.6)))
            }

            if template == .nightSky {
                // Add moon
                let moon = Circle().path(in: CGRect(x: 100*scaleX, y: 100*scaleY, width: 80*scaleX, height: 80*scaleY))
                context.fill(moon, with: .color(.yellow.opacity(0.7)))
            }

            if template == .deepSpace {
                // Add planet
                let planet = Circle().path(in: CGRect(x: size.width-250*scaleX, y: 150*scaleY, width: 120*scaleX, height: 120*scaleY))
                context.fill(planet, with: .color(.blue.opacity(0.3)))
            }

        case .galaxy:
            // Stars only (clouds handled by gradient view)
            for _ in 0..<30 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let circle = Circle().path(in: CGRect(x: x, y: y, width: 3*scaleX, height: 3*scaleY))
                context.fill(circle, with: .color(.white.opacity(0.7)))
            }

        case .stickyNote:
            // Horizontal lines
            for i in 0..<12 {
                let y = 150*scaleY + CGFloat(i) * (size.height / 15)
                let line = Path { path in
                    path.move(to: CGPoint(x: 50*scaleX, y: y))
                    path.addLine(to: CGPoint(x: size.width - 50*scaleX, y: y))
                }
                context.stroke(line, with: .color(.gray.opacity(0.2)), lineWidth: 1.5)
            }

        case .heartBorder:
            // Hearts at top and bottom
            let heartSize: CGFloat = 30 * scaleX
            let spacing: CGFloat = 60 * scaleX
            for i in 0..<Int(size.width/spacing) {
                let x = CGFloat(i) * spacing + 25*scaleX
                // Top hearts
                let topHeart = Circle().path(in: CGRect(x: x, y: 30*scaleY, width: heartSize, height: heartSize))
                context.fill(topHeart, with: .color(.pink.opacity(0.3)))
                // Bottom hearts
                let bottomHeart = Circle().path(in: CGRect(x: x, y: size.height - 60*scaleY, width: heartSize, height: heartSize))
                context.fill(bottomHeart, with: .color(.pink.opacity(0.3)))
            }

        case .floral:
            // Leaf decorations
            let leafPositions: [(CGFloat, CGFloat)] = [
                (100*scaleX, 100*scaleY),
                (size.width-150*scaleX, 150*scaleY),
                (150*scaleX, size.height-150*scaleY),
                (size.width-100*scaleX, size.height-120*scaleY)
            ]
            for (x, y) in leafPositions {
                let leaf = Ellipse().path(in: CGRect(x: x, y: y, width: 50*scaleX, height: 25*scaleY))
                context.fill(leaf, with: .color(.orange.opacity(0.2)))
            }

        case .craft:
            // Dashed border
            let border = Rectangle().path(in: CGRect(x: 40*scaleX, y: 40*scaleY, width: size.width - 80*scaleX, height: size.height - 80*scaleY))
            context.stroke(border, with: .color(.brown.opacity(0.3)), style: StrokeStyle(lineWidth: 2, dash: [10, 5]))

        case .vintage:
            // Corner ornaments
            let cornerSize: CGFloat = 100 * scaleX
            // Top left
            let tl = Circle().path(in: CGRect(x: 50*scaleX, y: 50*scaleY, width: cornerSize, height: cornerSize))
            context.stroke(tl, with: .color(.brown.opacity(0.3)), lineWidth: 1.5)
            // Top right
            let tr = Circle().path(in: CGRect(x: size.width - 150*scaleX, y: 50*scaleY, width: cornerSize, height: cornerSize))
            context.stroke(tr, with: .color(.brown.opacity(0.3)), lineWidth: 1.5)
            // Bottom left
            let bl = Circle().path(in: CGRect(x: 50*scaleX, y: size.height - 150*scaleY, width: cornerSize, height: cornerSize))
            context.stroke(bl, with: .color(.brown.opacity(0.3)), lineWidth: 1.5)
            // Bottom right
            let br = Circle().path(in: CGRect(x: size.width - 150*scaleX, y: size.height - 150*scaleY, width: cornerSize, height: cornerSize))
            context.stroke(br, with: .color(.brown.opacity(0.3)), lineWidth: 1.5)

        case .darkForest:
            // Dark leaves
            let leafPositions: [(CGFloat, CGFloat)] = [
                (150*scaleX, 200*scaleY),
                (250*scaleX, 300*scaleY),
                (size.width-200*scaleX, 250*scaleY),
                (200*scaleX, size.height-250*scaleY)
            ]
            for (x, y) in leafPositions {
                let leaf = Ellipse().path(in: CGRect(x: x, y: y, width: 60*scaleX, height: 30*scaleY))
                context.fill(leaf, with: .color(.green.opacity(0.4)))
            }

        case .charcoal:
            // Minimal frame
            let frame = Rectangle().path(in: CGRect(x: 50*scaleX, y: 50*scaleY, width: size.width - 100*scaleX, height: size.height - 100*scaleY))
            context.stroke(frame, with: .color(.white.opacity(0.2)), lineWidth: 1.5)

        case .blackboard:
            // Chalk lines
            let lineSpacing: CGFloat = 60 * scaleY
            for i in 0..<5 {
                let y = 200*scaleY + CGFloat(i) * lineSpacing
                let line = Rectangle().path(in: CGRect(x: 150*scaleX, y: y, width: size.width - 300*scaleX, height: 10*scaleY))
                context.fill(line, with: .color(.white.opacity(0.1)))
            }

        case .cyberpunk:
            // Neon horizontal stripes
            let stripes: [(Color, CGFloat)] = [
                (.cyan, 200*scaleY),
                (.pink, 300*scaleY),
                (.yellow, 400*scaleY),
                (.cyan, 500*scaleY),
                (.pink, 600*scaleY)
            ]
            for (color, y) in stripes {
                let line = Rectangle().path(in: CGRect(x: 100*scaleX, y: y, width: size.width - 200*scaleX, height: 8*scaleY))
                context.fill(line, with: .color(color.opacity(0.3)))
            }

        default:
            break
        }
    }
}

// MARK: - Color Extension
extension Color {
    func toHex() -> String {
        let components = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
