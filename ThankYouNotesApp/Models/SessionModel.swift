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
    // Light themes
    case blank = "blank"
    case stickyNote = "sticky_note"
    case watercolor = "watercolor"
    case confetti = "confetti"
    case heartBorder = "heart_border"
    case minimalist = "minimalist"
    case gradient = "gradient"
    case floral = "floral"
    case sunset = "sunset"
    case pastelRainbow = "pastel_rainbow"
    case craft = "craft"
    case vintage = "vintage"

    // Dark themes
    case midnight = "midnight"
    case neonGlow = "neon_glow"
    case deepSpace = "deep_space"
    case darkForest = "dark_forest"
    case charcoal = "charcoal"
    case galaxy = "galaxy"
    case darkGradient = "dark_gradient"
    case moody = "moody"
    case darkConfetti = "dark_confetti"
    case blackboard = "blackboard"
    case nightSky = "night_sky"
    case cyberpunk = "cyberpunk"

    var displayName: String {
        switch self {
        // Light themes
        case .blank: return "Blank"
        case .stickyNote: return "Sticky"
        case .watercolor: return "Water"
        case .confetti: return "Confetti"
        case .heartBorder: return "Hearts"
        case .minimalist: return "Minimal"
        case .gradient: return "Gradient"
        case .floral: return "Floral"
        case .sunset: return "Sunset"
        case .pastelRainbow: return "Rainbow"
        case .craft: return "Craft"
        case .vintage: return "Vintage"

        // Dark themes
        case .midnight: return "Midnight"
        case .neonGlow: return "Neon"
        case .deepSpace: return "Space"
        case .darkForest: return "Forest"
        case .charcoal: return "Charcoal"
        case .galaxy: return "Galaxy"
        case .darkGradient: return "Dark"
        case .moody: return "Moody"
        case .darkConfetti: return "Party"
        case .blackboard: return "Board"
        case .nightSky: return "Night"
        case .cyberpunk: return "Cyber"
        }
    }

    var backgroundColor: String {
        switch self {
        // Light themes
        case .blank: return "#FFFFFF"
        case .stickyNote: return "#FFF9C4"
        case .watercolor: return "#E3F2FD"
        case .confetti: return "#FFFFFF"
        case .heartBorder: return "#FCE4EC"
        case .minimalist: return "#FAFAFA"
        case .gradient: return "#F3E5F5"
        case .floral: return "#FFF3E0"
        case .sunset: return "#FFE5B4"
        case .pastelRainbow: return "#F5F0FF"
        case .craft: return "#F5E6D3"
        case .vintage: return "#FAF0E6"

        // Dark themes
        case .midnight: return "#0A1929"
        case .neonGlow: return "#1A0033"
        case .deepSpace: return "#0D1B2A"
        case .darkForest: return "#1B2A1F"
        case .charcoal: return "#2C2C2C"
        case .galaxy: return "#1C1551"
        case .darkGradient: return "#1F1B24"
        case .moody: return "#2A1F2D"
        case .darkConfetti: return "#1A1A2E"
        case .blackboard: return "#1E3A2B"
        case .nightSky: return "#0F1419"
        case .cyberpunk: return "#0D0221"
        }
    }

    var isDarkTheme: Bool {
        switch self {
        case .midnight, .neonGlow, .deepSpace, .darkForest, .charcoal, .galaxy,
             .darkGradient, .moody, .darkConfetti, .blackboard, .nightSky, .cyberpunk:
            return true
        default:
            return false
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
    var overlays: [CanvasOverlay] = []
    var sessionId: String = UUID().uuidString // For QR code photo uploads
}
