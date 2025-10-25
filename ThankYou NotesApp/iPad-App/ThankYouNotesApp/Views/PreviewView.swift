import SwiftUI
import PencilKit

struct PreviewView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var previewImage: UIImage?

    var body: some View {
        ZStack {
            Color.gray.opacity(0.2).ignoresSafeArea()

            VStack(spacing: 40) {
                // Header
                Text("Preview Your Note")
                    .font(.system(size: 64, weight: .bold))
                    .padding(.top, 100)

                // Preview card
                if let image = previewImage {
                    VStack(spacing: 30) {
                        // Recipient name (top)
                        Text("To: \(sessionManager.drawingState.recipient)")
                            .font(.system(size: 44, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 50)
                            .padding(.top, 40)

                        // Drawing preview
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 600)
                            .cornerRadius(24)
                            .shadow(radius: 15)
                            .padding(.horizontal, 50)

                        // Sender name (bottom)
                        Text("From: \(sessionManager.drawingState.sender)")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)
                            .italic()
                            .padding(.horizontal, 50)
                            .padding(.bottom, 40)
                    }
                    .background(Color.white)
                    .cornerRadius(32)
                    .shadow(radius: 25)
                    .padding(.horizontal, 100)
                } else {
                    ProgressView()
                        .scaleEffect(3.0)
                }

                Spacer()

                // Action buttons
                HStack(spacing: 40) {
                    Button(action: {
                        sessionManager.triggerHaptic(.light)
                        sessionManager.backToDrawing()
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.system(size: 36))
                            Text("Edit Drawing")
                                .font(.system(size: 36))
                        }
                        .foregroundColor(.gray)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 30)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                    }

                    Button(action: {
                        sessionManager.triggerHaptic(.medium)
                        sessionManager.submitNote()
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 40))
                            Text("Submit Note")
                                .font(.system(size: 40, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
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
                        .cornerRadius(20)
                        .shadow(color: Color(red: 0.8, green: 0.3, blue: 0.9).opacity(0.5), radius: 15, y: 10)
                    }
                }
                .padding(.horizontal, 100)
                .padding(.bottom, 80)
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

            // Draw template decorations
            drawTemplateDecorations(context: context.cgContext, size: canvasSize, template: sessionManager.drawingState.template)

            // LAYER 1: Draw photo overlays first (bottom layer)
            for overlay in sessionManager.drawingState.overlays.filter({ $0.type == .photo }) {
                context.cgContext.saveGState()
                context.cgContext.translateBy(x: overlay.position.x, y: overlay.position.y)
                context.cgContext.rotate(by: overlay.rotation * .pi / 180)
                context.cgContext.scaleBy(x: overlay.scale, y: overlay.scale)

                if let imageData = Data(base64Encoded: overlay.content),
                   let photoImage = UIImage(data: imageData) {
                    // Use stored image size, or calculate from actual image with max dimension of 200
                    let photoSize: CGSize
                    if let storedSize = overlay.imageSize {
                        // Scale to fit within 200x200 while maintaining aspect ratio
                        let maxDimension: CGFloat = 200
                        let scale = min(maxDimension / storedSize.width, maxDimension / storedSize.height)
                        photoSize = CGSize(width: storedSize.width * scale, height: storedSize.height * scale)
                    } else {
                        // Fallback: calculate from actual image
                        let maxDimension: CGFloat = 200
                        let scale = min(maxDimension / photoImage.size.width, maxDimension / photoImage.size.height)
                        photoSize = CGSize(width: photoImage.size.width * scale, height: photoImage.size.height * scale)
                    }

                    let photoRect = CGRect(x: -photoSize.width/2, y: -photoSize.height/2,
                                         width: photoSize.width, height: photoSize.height)

                    // Add rounded corners (fixed size, not affected by user scaling)
                    let cornerRadius: CGFloat = 12
                    let path = UIBezierPath(roundedRect: photoRect, cornerRadius: cornerRadius)
                    context.cgContext.addPath(path.cgPath)
                    context.cgContext.clip()

                    photoImage.draw(in: photoRect)
                }

                context.cgContext.restoreGState()
            }

            // LAYER 2: Draw the PKDrawing on top of photos
            // Get drawing at its natural bounds, then scale to fill canvas
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

            // LAYER 3: Draw emoji and text overlays on top
            for overlay in sessionManager.drawingState.overlays.filter({ $0.type != .photo }) {
                context.cgContext.saveGState()
                context.cgContext.translateBy(x: overlay.position.x, y: overlay.position.y)
                context.cgContext.rotate(by: overlay.rotation * .pi / 180)
                context.cgContext.scaleBy(x: overlay.scale, y: overlay.scale)

                switch overlay.type {
                case .emoji:
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 120), // Doubled to match canvas
                    ]
                    let emojiString = overlay.content as NSString
                    let size = emojiString.size(withAttributes: attributes)
                    emojiString.draw(at: CGPoint(x: -size.width/2, y: -size.height/2), withAttributes: attributes)

                case .text:
                    let fontSize = overlay.fontSize ?? 48
                    let font: UIFont = {
                        if let fontName = overlay.fontName {
                            // Map font names to UIFont
                            if let customFont = UIFont(name: fontName, size: fontSize) {
                                return customFont
                            }
                        }
                        return UIFont.boldSystemFont(ofSize: fontSize)
                    }()

                    // Determine max width based on text style (title = smaller width, paragraph = wider)
                    let maxWidth: CGFloat = fontSize <= 30 ? 800 : 600 // Smaller for captions/paragraphs, larger for titles

                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.alignment = .center

                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: font,
                        .foregroundColor: UIColor(hexString: overlay.textColor ?? "#FFFFFF"),
                        .paragraphStyle: paragraphStyle
                    ]

                    let textString = overlay.content as NSString

                    // Calculate the bounding rect for multi-line text
                    let boundingRect = textString.boundingRect(
                        with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                        attributes: attributes,
                        context: nil
                    )

                    // Draw text in rect centered at position
                    let drawRect = CGRect(
                        x: -boundingRect.width / 2,
                        y: -boundingRect.height / 2,
                        width: boundingRect.width,
                        height: boundingRect.height
                    )

                    textString.draw(in: drawRect, withAttributes: attributes)

                case .photo:
                    break // Already drawn in layer 1
                }

                context.cgContext.restoreGState()
            }
        }

        previewImage = image
        sessionManager.drawingState.canvasImage = image
    }

    private func drawTemplateDecorations(context: CGContext, size: CGSize, template: TemplateTheme) {
        switch template {
        // Light themes
        case .blank, .minimalist:
            break

        case .stickyNote:
            // Horizontal lines
            UIColor.gray.withAlphaComponent(0.2).setStroke()
            context.setLineWidth(2)
            let lineSpacing: CGFloat = size.height / 15
            for i in 0..<12 {
                let y = 300 + CGFloat(i) * lineSpacing
                context.move(to: CGPoint(x: 100, y: y))
                context.addLine(to: CGPoint(x: size.width - 100, y: y))
            }
            context.strokePath()

        case .watercolor:
            // Watercolor blobs with radial gradient
            // First blob - blue
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let blueCenter = CGPoint(x: 300, y: 350)
            let blueColors = [UIColor.blue.withAlphaComponent(0.2).cgColor, UIColor.blue.withAlphaComponent(0.1).cgColor, UIColor.clear.cgColor] as CFArray
            if let blueGradient = CGGradient(colorsSpace: colorSpace, colors: blueColors, locations: [0.0, 0.5, 1.0]) {
                context.drawRadialGradient(blueGradient, startCenter: blueCenter, startRadius: 0, endCenter: blueCenter, endRadius: 150, options: [])
            }

            // Second blob - purple
            let purpleCenter = CGPoint(x: size.width - 250, y: size.height - 250)
            let purpleColors = [UIColor.purple.withAlphaComponent(0.15).cgColor, UIColor.purple.withAlphaComponent(0.08).cgColor, UIColor.clear.cgColor] as CFArray
            if let purpleGradient = CGGradient(colorsSpace: colorSpace, colors: purpleColors, locations: [0.0, 0.5, 1.0]) {
                context.drawRadialGradient(purpleGradient, startCenter: purpleCenter, startRadius: 0, endCenter: purpleCenter, endRadius: 120, options: [])
            }

        case .confetti:
            // Random confetti dots
            let colors: [UIColor] = [.red, .blue, .yellow, .green, .systemPink]
            for _ in 0..<50 {
                colors.randomElement()?.setFill()
                let x = CGFloat.random(in: 100...(size.width-100))
                let y = CGFloat.random(in: 100...(size.height-100))
                context.fillEllipse(in: CGRect(x: x, y: y, width: 20, height: 20))
            }

        case .heartBorder:
            // Hearts at top and bottom
            UIColor.systemPink.withAlphaComponent(0.3).setFill()
            let heartSize: CGFloat = 40
            let spacing: CGFloat = 80
            for i in 0..<Int(size.width/spacing) {
                let x = CGFloat(i) * spacing + 50
                // Top hearts
                context.fillEllipse(in: CGRect(x: x, y: 50, width: heartSize, height: heartSize))
                // Bottom hearts
                context.fillEllipse(in: CGRect(x: x, y: size.height - 90, width: heartSize, height: heartSize))
            }

        case .gradient:
            // Linear gradient overlay
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradColors = [
                UIColor.purple.withAlphaComponent(0.3).cgColor,
                UIColor.systemPink.withAlphaComponent(0.25).cgColor,
                UIColor.orange.withAlphaComponent(0.2).cgColor
            ] as CFArray
            if let linearGrad = CGGradient(colorsSpace: colorSpace, colors: gradColors, locations: [0.0, 0.5, 1.0]) {
                context.drawLinearGradient(linearGrad, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: size.height), options: [])
            }

        case .floral:
            // Leaf decorations
            UIColor.orange.withAlphaComponent(0.2).setFill()
            let leafPositions = [(200, 200), (size.width-250, 300), (300, size.height-300), (size.width-200, size.height-250)]
            for (x, y) in leafPositions {
                context.fillEllipse(in: CGRect(x: x, y: y, width: 60, height: 30))
            }

            // Soft peachy gradient overlay
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let floralCenter = CGPoint(x: size.width / 2, y: size.height / 2)
            let floralColors = [
                UIColor.clear.cgColor,
                UIColor.orange.withAlphaComponent(0.1).cgColor,
                UIColor.orange.withAlphaComponent(0.05).cgColor
            ] as CFArray
            if let floralGrad = CGGradient(colorsSpace: colorSpace, colors: floralColors, locations: [0.0, 0.5, 1.0]) {
                context.drawRadialGradient(floralGrad, startCenter: floralCenter, startRadius: 100, endCenter: floralCenter, endRadius: 300, options: [])
            }

        case .sunset:
            // Smooth gradient bands with linear gradients
            let colorSpace = CGColorSpaceCreateDeviceRGB()

            // Top gradient (orange fade)
            let topColors = [
                UIColor.orange.withAlphaComponent(0.5).cgColor,
                UIColor.orange.withAlphaComponent(0.3).cgColor
            ] as CFArray
            if let topGrad = CGGradient(colorsSpace: colorSpace, colors: topColors, locations: [0.0, 1.0]) {
                context.drawLinearGradient(topGrad, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: size.height / 3), options: [])
            }

            // Middle gradient (orange to pink)
            let midColors = [
                UIColor.orange.withAlphaComponent(0.3).cgColor,
                UIColor.systemPink.withAlphaComponent(0.35).cgColor,
                UIColor.systemPink.withAlphaComponent(0.25).cgColor
            ] as CFArray
            if let midGrad = CGGradient(colorsSpace: colorSpace, colors: midColors, locations: [0.0, 0.5, 1.0]) {
                context.drawLinearGradient(midGrad, start: CGPoint(x: 0, y: size.height / 3), end: CGPoint(x: 0, y: 2 * size.height / 3), options: [])
            }

            // Bottom gradient (pink to purple)
            let botColors = [
                UIColor.systemPink.withAlphaComponent(0.25).cgColor,
                UIColor.purple.withAlphaComponent(0.2).cgColor
            ] as CFArray
            if let botGrad = CGGradient(colorsSpace: colorSpace, colors: botColors, locations: [0.0, 1.0]) {
                context.drawLinearGradient(botGrad, start: CGPoint(x: 0, y: 2 * size.height / 3), end: CGPoint(x: 0, y: size.height), options: [])
            }

        case .pastelRainbow:
            // Rainbow stripes
            let colors: [UIColor] = [.red, .orange, .yellow, .green, .blue, .purple]
            let stripeWidth = size.width / CGFloat(colors.count)
            for (index, color) in colors.enumerated() {
                color.withAlphaComponent(0.2).setFill()
                context.fill(CGRect(x: CGFloat(index) * stripeWidth, y: 0, width: stripeWidth, height: size.height))
            }

        case .craft:
            // Dashed border
            UIColor.brown.withAlphaComponent(0.3).setStroke()
            context.setLineWidth(3)
            context.setLineDash(phase: 0, lengths: [15, 10])
            context.stroke(CGRect(x: 80, y: 80, width: size.width - 160, height: size.height - 160))
            context.setLineDash(phase: 0, lengths: [])

        case .vintage:
            // Corner ornaments
            UIColor.brown.withAlphaComponent(0.3).setStroke()
            context.setLineWidth(2)
            // Top left
            context.strokeEllipse(in: CGRect(x: 100, y: 100, width: 150, height: 150))
            // Top right
            context.strokeEllipse(in: CGRect(x: size.width - 250, y: 100, width: 150, height: 150))
            // Bottom left
            context.strokeEllipse(in: CGRect(x: 100, y: size.height - 250, width: 150, height: 150))
            // Bottom right
            context.strokeEllipse(in: CGRect(x: size.width - 250, y: size.height - 250, width: 150, height: 150))

        // Dark themes
        case .midnight:
            // Stars
            UIColor.white.withAlphaComponent(0.6).setFill()
            for _ in 0..<30 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                context.fillEllipse(in: CGRect(x: x, y: y, width: 6, height: 6))
            }

        case .neonGlow:
            // Neon glow with radial gradients
            let colorSpace = CGColorSpaceCreateDeviceRGB()

            // Cyan glow
            let cyanCenter = CGPoint(x: size.width * 0.25, y: size.height * 0.3)
            let cyanColors = [
                UIColor.cyan.withAlphaComponent(0.6).cgColor,
                UIColor.cyan.withAlphaComponent(0.2).cgColor,
                UIColor.clear.cgColor
            ] as CFArray
            if let cyanGradient = CGGradient(colorsSpace: colorSpace, colors: cyanColors, locations: [0.0, 0.5, 1.0]) {
                context.drawRadialGradient(cyanGradient, startCenter: cyanCenter, startRadius: 0, endCenter: cyanCenter, endRadius: 100, options: [])
            }

            // Pink glow
            let pinkCenter = CGPoint(x: size.width * 0.75, y: size.height * 0.7)
            let pinkColors = [
                UIColor.systemPink.withAlphaComponent(0.6).cgColor,
                UIColor.systemPink.withAlphaComponent(0.2).cgColor,
                UIColor.clear.cgColor
            ] as CFArray
            if let pinkGradient = CGGradient(colorsSpace: colorSpace, colors: pinkColors, locations: [0.0, 0.5, 1.0]) {
                context.drawRadialGradient(pinkGradient, startCenter: pinkCenter, startRadius: 0, endCenter: pinkCenter, endRadius: 120, options: [])
            }

        case .deepSpace:
            // Stars and planet
            UIColor.white.withAlphaComponent(0.8).setFill()
            for _ in 0..<40 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                context.fillEllipse(in: CGRect(x: x, y: y, width: 5, height: 5))
            }
            UIColor.blue.withAlphaComponent(0.3).setFill()
            context.fillEllipse(in: CGRect(x: size.width - 400, y: 300, width: 200, height: 200))

        case .darkForest:
            // Dark leaves
            UIColor.green.withAlphaComponent(0.4).setFill()
            let leafPositions = [(300, 400), (500, 600), (size.width-400, 500), (400, size.height-500)]
            for (x, y) in leafPositions {
                context.fillEllipse(in: CGRect(x: x, y: y, width: 80, height: 40))
            }

        case .charcoal:
            // Minimal frame
            UIColor.white.withAlphaComponent(0.2).setStroke()
            context.setLineWidth(2)
            context.stroke(CGRect(x: 100, y: 100, width: size.width - 200, height: size.height - 200))

        case .galaxy:
            // Galaxy effect with radial gradient nebulas
            let colorSpace = CGColorSpaceCreateDeviceRGB()

            // Purple nebula
            let purpleCenter = CGPoint(x: size.width * 0.3, y: size.height * 0.35)
            let purpleColors = [UIColor.purple.withAlphaComponent(0.4).cgColor, UIColor.purple.withAlphaComponent(0.2).cgColor, UIColor.clear.cgColor] as CFArray
            if let purpleGrad = CGGradient(colorsSpace: colorSpace, colors: purpleColors, locations: [0.0, 0.5, 1.0]) {
                context.drawRadialGradient(purpleGrad, startCenter: purpleCenter, startRadius: 0, endCenter: purpleCenter, endRadius: 200, options: [])
            }

            // Blue nebula
            let blueCenter = CGPoint(x: size.width * 0.6, y: size.height * 0.55)
            let blueColors = [UIColor.blue.withAlphaComponent(0.3).cgColor, UIColor.blue.withAlphaComponent(0.15).cgColor, UIColor.clear.cgColor] as CFArray
            if let blueGrad = CGGradient(colorsSpace: colorSpace, colors: blueColors, locations: [0.0, 0.5, 1.0]) {
                context.drawRadialGradient(blueGrad, startCenter: blueCenter, startRadius: 0, endCenter: blueCenter, endRadius: 180, options: [])
            }

            // Pink nebula
            let pinkCenter = CGPoint(x: size.width * 0.5, y: size.height * 0.7)
            let pinkColors = [UIColor.systemPink.withAlphaComponent(0.25).cgColor, UIColor.systemPink.withAlphaComponent(0.1).cgColor, UIColor.clear.cgColor] as CFArray
            if let pinkGrad = CGGradient(colorsSpace: colorSpace, colors: pinkColors, locations: [0.0, 0.5, 1.0]) {
                context.drawRadialGradient(pinkGrad, startCenter: pinkCenter, startRadius: 0, endCenter: pinkCenter, endRadius: 150, options: [])
            }

            // Stars
            UIColor.white.withAlphaComponent(0.7).setFill()
            for _ in 0..<30 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                context.fillEllipse(in: CGRect(x: x, y: y, width: 3, height: 3))
            }

        case .darkGradient:
            // Dark gradient from deep purple to black
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let darkGradColors = [
                UIColor.purple.withAlphaComponent(0.4).cgColor,
                UIColor.purple.withAlphaComponent(0.2).cgColor,
                UIColor.black.withAlphaComponent(0.3).cgColor
            ] as CFArray
            if let darkGrad = CGGradient(colorsSpace: colorSpace, colors: darkGradColors, locations: [0.0, 0.5, 1.0]) {
                context.drawLinearGradient(darkGrad, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: size.height), options: [])
            }

        case .moody:
            // Purple glow with radial gradient
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let moodyCent = CGPoint(x: size.width/2, y: size.height/2)
            let moodyColors = [
                UIColor.purple.withAlphaComponent(0.5).cgColor,
                UIColor.purple.withAlphaComponent(0.3).cgColor,
                UIColor.purple.withAlphaComponent(0.1).cgColor,
                UIColor.clear.cgColor
            ] as CFArray
            if let moodyGradient = CGGradient(colorsSpace: colorSpace, colors: moodyColors, locations: [0.0, 0.4, 0.7, 1.0]) {
                context.drawRadialGradient(moodyGradient, startCenter: moodyCent, startRadius: 0, endCenter: moodyCent, endRadius: 200, options: [])
            }

        case .darkConfetti:
            // Neon confetti
            let colors: [UIColor] = [.cyan, .systemPink, .yellow, .green]
            for _ in 0..<50 {
                colors.randomElement()?.setFill()
                let x = CGFloat.random(in: 100...(size.width-100))
                let y = CGFloat.random(in: 100...(size.height-100))
                context.fillEllipse(in: CGRect(x: x, y: y, width: 20, height: 20))
            }

        case .blackboard:
            // Chalk lines
            UIColor.white.withAlphaComponent(0.1).setFill()
            let lineSpacing: CGFloat = 100
            for i in 0..<5 {
                let y = 400 + CGFloat(i) * lineSpacing
                context.fill(CGRect(x: 300, y: y, width: size.width - 600, height: 15))
            }

        case .nightSky:
            // Moon and stars
            UIColor.yellow.withAlphaComponent(0.7).setFill()
            context.fillEllipse(in: CGRect(x: 200, y: 200, width: 120, height: 120))
            UIColor.white.withAlphaComponent(0.6).setFill()
            for _ in 0..<25 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                context.fillEllipse(in: CGRect(x: x, y: y, width: 8, height: 8))
            }

        case .cyberpunk:
            // Neon horizontal stripes
            let colors: [(UIColor, CGFloat)] = [
                (.cyan, 400),
                (.systemPink, 600),
                (.yellow, 800),
                (.cyan, 1000),
                (.systemPink, 1200)
            ]
            for (color, y) in colors {
                color.withAlphaComponent(0.3).setFill()
                context.fill(CGRect(x: 200, y: y, width: size.width - 400, height: 12))
            }
        }
    }
}

#Preview {
    PreviewView()
        .environmentObject(SessionManager())
}
