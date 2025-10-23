import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import PencilKit
import Combine
import UIKit

class FirebaseService {
    private let database: DatabaseReference
    private let storage: Storage
    private var connectionRef: DatabaseReference
    private let connectionSubject = CurrentValueSubject<Bool, Never>(false)

    var connectionStatus: AnyPublisher<Bool, Never> {
        connectionSubject.eraseToAnyPublisher()
    }

    init() {
        self.database = Database.database().reference()
        self.storage = Storage.storage()
        self.connectionRef = Database.database().reference(withPath: ".info/connected")

        setupConnectionMonitoring()
    }

    // MARK: - Connection Monitoring
    private func setupConnectionMonitoring() {
        connectionRef.observe(.value) { [weak self] snapshot in
            guard let connected = snapshot.value as? Bool else { return }
            self?.connectionSubject.send(connected)
        }
    }

    // MARK: - Photo Upload Listener
    func listenForPhotoUpload(sessionId: String, completion: @escaping (String?) -> Void) -> DatabaseHandle {
        let photoRef = database.child("photos").child(sessionId)

        let handle = photoRef.observe(.value) { snapshot in
            guard snapshot.exists() else {
                return
            }

            guard let photoData = snapshot.value as? [String: Any],
                  let imageData = photoData["imageData"] as? String else {
                return
            }

            completion(imageData)
        }

        return handle
    }

    func removePhotoListener(sessionId: String, handle: DatabaseHandle) {
        let photoRef = database.child("photos").child(sessionId)
        photoRef.removeObserver(withHandle: handle)
    }

    // MARK: - Submit Session
    func submitSession(drawingState: DrawingState) async throws {
        let sessionId = UUID().uuidString
        let timestamp = Date().timeIntervalSince1970

        // Use the pre-rendered canvasImage from preview (includes overlays)
        // If not available, fall back to generating from PKDrawing only
        let drawingImage: UIImage
        if let canvasImage = drawingState.canvasImage {
            drawingImage = canvasImage
        } else {
            guard let generatedImage = await convertDrawingToImage(drawingState.drawing, template: drawingState.template) else {
                throw FirebaseError.imageConversionFailed
            }
            drawingImage = generatedImage
        }

        // Convert to base64
        guard let imageData = drawingImage.pngData() else {
            throw FirebaseError.imageConversionFailed
        }
        let base64Image = imageData.base64EncodedString()

        // Optionally save raw drawing data
        let rawDrawingData = drawingState.drawing.dataRepresentation().base64EncodedString()

        // Create session data
        let iPadInput = SessionData.IPadInput(
            recipient: drawingState.recipient,
            sender: drawingState.sender,
            drawingImage: base64Image,
            templateTheme: drawingState.template.rawValue,
            rawDrawingData: rawDrawingData
        )

        let session = SessionData(
            sessionId: sessionId,
            status: .pending,
            createdAt: timestamp,
            displayedAt: nil,
            expiresAt: timestamp + 3600, // 1 hour TTL
            iPadInput: iPadInput
        )

        // Upload to Firebase
        try await uploadSession(session)
    }

    private func uploadSession(_ session: SessionData) async throws {
        let sessionRef = database.child("sessions").child(session.sessionId)

        let encoder = JSONEncoder()
        let data = try encoder.encode(session)

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw FirebaseError.encodingFailed
        }

        try await sessionRef.setValue(json)
    }

    // MARK: - Image Conversion
    private func convertDrawingToImage(_ drawing: PKDrawing, template: TemplateTheme) async -> UIImage? {
        let canvasSize = CGSize(width: 1200, height: 1600) // 16:9 aspect ratio scaled
        let renderer = UIGraphicsImageRenderer(size: canvasSize)

        let image = renderer.image { context in
            // Draw template background
            let backgroundColor = UIColor(hexString: template.backgroundColor)
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: canvasSize))

            // Draw template pattern (if any)
            drawTemplatePattern(template, in: context.cgContext, size: canvasSize)

            // Draw PKDrawing on top
            // Use the full canvas size as the drawing bounds
            let drawingRect = CGRect(origin: .zero, size: canvasSize)
            let drawingImage = drawing.image(from: drawingRect, scale: 1.0)
            drawingImage.draw(in: drawingRect)
        }

        return image
    }

    private func drawTemplatePattern(_ template: TemplateTheme, in context: CGContext, size: CGSize) {
        switch template {
        case .stickyNote:
            // Add horizontal lines
            context.setStrokeColor(UIColor.lightGray.withAlphaComponent(0.3).cgColor)
            context.setLineWidth(1.5)
            let lineSpacing: CGFloat = 40
            for i in stride(from: lineSpacing, to: size.height, by: lineSpacing) {
                context.move(to: CGPoint(x: 20, y: i))
                context.addLine(to: CGPoint(x: size.width - 20, y: i))
            }
            context.strokePath()

        case .confetti:
            // Draw random confetti shapes
            let colors: [UIColor] = [.systemRed, .systemBlue, .systemYellow, .systemGreen, .systemPink]
            for _ in 0..<50 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let size = CGFloat.random(in: 5...15)
                let color = colors.randomElement() ?? .systemBlue
                color.setFill()
                context.fillEllipse(in: CGRect(x: x, y: y, width: size, height: size))
            }

        case .heartBorder:
            // Draw heart shapes around border
            context.setFillColor(UIColor.systemPink.withAlphaComponent(0.2).cgColor)
            for i in stride(from: 0, to: size.width, by: 60) {
                drawHeart(in: context, at: CGPoint(x: i, y: 20), size: 20)
                drawHeart(in: context, at: CGPoint(x: i, y: size.height - 40), size: 20)
            }

        default:
            break
        }
    }

    private func drawHeart(in context: CGContext, at point: CGPoint, size: CGFloat) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: point.x + size / 2, y: point.y + size))
        path.addCurve(
            to: CGPoint(x: point.x, y: point.y + size / 3),
            control1: CGPoint(x: point.x + size / 2, y: point.y + size * 2 / 3),
            control2: CGPoint(x: point.x, y: point.y + size * 2 / 3)
        )
        path.addArc(
            center: CGPoint(x: point.x + size / 4, y: point.y + size / 3),
            radius: size / 4,
            startAngle: .pi,
            endAngle: 0,
            clockwise: false
        )
        path.addArc(
            center: CGPoint(x: point.x + size * 3 / 4, y: point.y + size / 3),
            radius: size / 4,
            startAngle: .pi,
            endAngle: 0,
            clockwise: false
        )
        path.addCurve(
            to: CGPoint(x: point.x + size / 2, y: point.y + size),
            control1: CGPoint(x: point.x + size, y: point.y + size * 2 / 3),
            control2: CGPoint(x: point.x + size / 2, y: point.y + size * 2 / 3)
        )
        context.addPath(path)
        context.fillPath()
    }
}

// MARK: - Errors
enum FirebaseError: LocalizedError {
    case imageConversionFailed
    case encodingFailed
    case uploadFailed

    var errorDescription: String? {
        switch self {
        case .imageConversionFailed: return "Failed to convert drawing to image"
        case .encodingFailed: return "Failed to encode session data"
        case .uploadFailed: return "Failed to upload to Firebase"
        }
    }
}

// MARK: - UIColor Extension
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

// MARK: - SwiftUI Color Extension
import SwiftUI

extension Color {
    init(hexString: String) {
        let uiColor = UIColor(hexString: hexString)
        self.init(uiColor)
    }
}
