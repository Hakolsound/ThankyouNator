import SwiftUI
import PencilKit

struct PreviewView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var previewImage: UIImage?

    var body: some View {
        ZStack {
            Color.gray.opacity(0.2).ignoresSafeArea()

            VStack(spacing: 30) {
                // Header
                Text("Preview Your Note")
                    .font(.system(size: 42, weight: .semibold))
                    .padding(.top, 60)

                // Preview card
                if let image = previewImage {
                    VStack(spacing: 20) {
                        // Recipient name (top)
                        Text("To: \(sessionManager.drawingState.recipient)")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 40)
                            .padding(.top, 30)

                        // Drawing preview
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 600)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                            .padding(.horizontal, 40)

                        // Sender name (bottom)
                        Text("From: \(sessionManager.drawingState.sender)")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                            .italic()
                            .padding(.horizontal, 40)
                            .padding(.bottom, 30)
                    }
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(radius: 20)
                    .padding(.horizontal, 80)
                } else {
                    ProgressView()
                        .scaleEffect(2.0)
                }

                Spacer()

                // Action buttons
                HStack(spacing: 30) {
                    Button(action: {
                        sessionManager.triggerHaptic(.light)
                        sessionManager.backToDrawing()
                    }) {
                        HStack {
                            Image(systemName: "arrow.left.circle.fill")
                            Text("Edit Drawing")
                        }
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    }

                    Button(action: {
                        sessionManager.triggerHaptic(.medium)
                        sessionManager.submitNote()
                    }) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Submit Note")
                        }
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            LinearGradient(
                                colors: [Color.green, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    }
                }
                .padding(.horizontal, 80)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            generatePreview()
        }
    }

    private func generatePreview() {
        let canvasSize = CGSize(width: 1200, height: 1600)
        let renderer = UIGraphicsImageRenderer(size: canvasSize)

        let image = renderer.image { context in
            // Draw template background
            let backgroundColor = UIColor(hexString: sessionManager.drawingState.template.backgroundColor)
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: canvasSize))

            // Draw the PKDrawing with proper scaling
            if !sessionManager.drawingState.drawing.bounds.isEmpty {
                let drawingBounds = sessionManager.drawingState.drawing.bounds

                // Calculate scale to fit drawing bounds into canvas size
                let scaleX = canvasSize.width / drawingBounds.width
                let scaleY = canvasSize.height / drawingBounds.height
                let scale = min(scaleX, scaleY)

                // Get drawing image at its natural size with appropriate scale
                let drawingImage = sessionManager.drawingState.drawing.image(
                    from: drawingBounds,
                    scale: scale
                )

                // Calculate position to center the scaled drawing
                let scaledWidth = drawingBounds.width * scale
                let scaledHeight = drawingBounds.height * scale
                let x = (canvasSize.width - scaledWidth) / 2
                let y = (canvasSize.height - scaledHeight) / 2

                drawingImage.draw(in: CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight))
            }
        }

        previewImage = image
        sessionManager.drawingState.canvasImage = image
    }
}

#Preview {
    PreviewView()
        .environmentObject(SessionManager())
}
