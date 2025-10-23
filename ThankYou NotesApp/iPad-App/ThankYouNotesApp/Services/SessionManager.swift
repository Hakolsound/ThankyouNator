import SwiftUI
import Combine
import PencilKit

// MARK: - App State
enum AppState {
    case welcome
    case input
    case templateSelection
    case drawing
    case preview
    case submitting
    case complete
}

// MARK: - Session Manager
class SessionManager: ObservableObject {
    @Published var currentState: AppState = .welcome
    @Published var drawingState = DrawingState()
    @Published var isConnected: Bool = false
    @Published var lastError: String?

    private let firebaseService = FirebaseService()
    private var cancellables = Set<AnyCancellable>()
    private var idleTimer: Timer?

    init() {
        setupConnectionMonitoring()
        startIdleTimer()
    }

    // MARK: - Navigation
    func startNewNote() {
        resetDrawingState()
        currentState = .input
        resetIdleTimer()
    }

    func proceedToTemplateSelection() {
        guard !drawingState.recipient.isEmpty else {
            lastError = "Please enter a recipient name"
            return
        }
        currentState = .templateSelection
        resetIdleTimer()
    }

    func selectTemplate(_ template: TemplateTheme) {
        drawingState.template = template
        currentState = .drawing
        resetIdleTimer()
    }

    func proceedToPreview() {
        currentState = .preview
        resetIdleTimer()
    }

    func backToDrawing() {
        currentState = .drawing
        resetIdleTimer()
    }

    func submitNote() {
        currentState = .submitting

        Task {
            do {
                try await firebaseService.submitSession(drawingState: drawingState)
                await MainActor.run {
                    self.currentState = .complete
                    self.scheduleReturnToWelcome()
                }
            } catch {
                await MainActor.run {
                    self.lastError = "Failed to submit: \(error.localizedDescription)"
                    self.currentState = .preview
                }
            }
        }
    }

    // MARK: - State Management
    private func resetDrawingState() {
        drawingState = DrawingState()
        lastError = nil
    }

    private func scheduleReturnToWelcome() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.currentState = .welcome
            self?.resetDrawingState()
        }
    }

    // MARK: - Connection Monitoring
    private func setupConnectionMonitoring() {
        firebaseService.connectionStatus
            .receive(on: DispatchQueue.main)
            .assign(to: &$isConnected)
    }

    // MARK: - Idle Timer
    private func startIdleTimer() {
        idleTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.handleIdleTimeout()
        }
    }

    private func resetIdleTimer() {
        idleTimer?.invalidate()
        startIdleTimer()
    }

    private func handleIdleTimeout() {
        if currentState != .welcome && currentState != .complete {
            currentState = .welcome
            resetDrawingState()
        }
    }

    // MARK: - Haptic Feedback
    func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
