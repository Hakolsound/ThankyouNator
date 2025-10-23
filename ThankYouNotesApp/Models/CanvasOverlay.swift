import SwiftUI

// Model for overlays (emojis, text, stickers, photos)
struct CanvasOverlay: Identifiable, Codable {
    let id: UUID
    var type: OverlayType
    var position: CGPoint
    var scale: CGFloat
    var rotation: Double
    var content: String // emoji, text content, or base64 image
    var textColor: String? // hex color for text
    var fontSize: CGFloat?
    var imageSize: CGSize? // Original dimensions for photos
    var fontName: String? // Font family name for text

    enum OverlayType: String, Codable {
        case emoji
        case text
        case photo
    }

    init(id: UUID = UUID(), type: OverlayType, position: CGPoint, scale: CGFloat = 1.0, rotation: Double = 0, content: String, textColor: String? = nil, fontSize: CGFloat? = nil, imageSize: CGSize? = nil, fontName: String? = nil) {
        self.id = id
        self.type = type
        self.position = position
        self.scale = scale
        self.rotation = rotation
        self.content = content
        self.textColor = textColor
        self.fontSize = fontSize
        self.imageSize = imageSize
        self.fontName = fontName
    }
}
