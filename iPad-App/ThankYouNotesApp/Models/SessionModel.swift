import Foundation
import PencilKit

// MARK: - Session Status
enum SessionStatus: String, Codable {
    case pending = "pending"
    case readyForDisplay = "ready_for_display"
    case displaying = "displaying"
    case complete = "complete"
}

// MARK: - Template Theme
enum TemplateTheme: String, Codable, CaseIterable {
    case blank = "blank"
    case stickyNote = "sticky_note"
    case watercolor = "watercolor"
    case confetti = "confetti"
    case heartBorder = "heart_border"
    case minimalist = "minimalist"
    case gradient = "gradient"
    case floral = "floral"

    var displayName: String {
        switch self {
        case .blank: return "Blank Canvas"
        case .stickyNote: return "Sticky Note"
        case .watercolor: return "Watercolor"
        case .confetti: return "Confetti"
        case .heartBorder: return "Heart Border"
        case .minimalist: return "Minimalist"
        case .gradient: return "Gradient"
        case .floral: return "Floral"
        }
    }

    var backgroundColor: String {
        switch self {
        case .blank: return "#FFFFFF"
        case .stickyNote: return "#FFF9C4"
        case .watercolor: return "#E3F2FD"
        case .confetti: return "#FFFFFF"
        case .heartBorder: return "#FCE4EC"
        case .minimalist: return "#FAFAFA"
        case .gradient: return "#F3E5F5"
        case .floral: return "#FFF3E0"
        }
    }
}

// MARK: - Session Data
struct SessionData: Codable {
    let sessionId: String
    var status: SessionStatus
    let createdAt: TimeInterval
    var displayedAt: TimeInterval?
    var expiresAt: TimeInterval
    var iPadInput: IPadInput

    struct IPadInput: Codable {
        let recipient: String
        let sender: String
        let drawingImage: String // base64 encoded PNG
        let templateTheme: String
        var rawDrawingData: String? // PKDrawing binary data (optional)
    }

    enum CodingKeys: String, CodingKey {
        case sessionId
        case status
        case createdAt
        case displayedAt
        case expiresAt
        case iPadInput = "iPad_input"
    }
}

// MARK: - Drawing State
struct DrawingState {
    var recipient: String = ""
    var sender: String = ""
    var template: TemplateTheme = .blank
    var drawing: PKDrawing = PKDrawing()
    var canvasImage: UIImage?
}
