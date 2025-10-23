import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        ZStack {
            // Main content
            switch sessionManager.currentState {
            case .welcome:
                WelcomeView()
            case .input:
                InputView()
            case .templateSelection:
                TemplateSelectionView()
            case .drawing:
                EnhancedDrawingCanvasView()
            case .preview:
                PreviewView()
            case .submitting:
                SubmittingView()
            case .complete:
                CompletionView()
            }

            // Connection status indicator (top right)
            VStack {
                HStack {
                    Spacer()
                    ConnectionStatusView(isConnected: sessionManager.isConnected)
                        .padding()
                }
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Connection Status View
struct ConnectionStatusView: View {
    let isConnected: Bool

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isConnected ? Color.green : Color.red)
                .frame(width: 12, height: 12)
            Text(isConnected ? "Connected" : "Offline")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

// MARK: - Submitting View
struct SubmittingView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 30) {
                ProgressView()
                    .scaleEffect(2.0)

                Text("Submitting your note...")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Completion View
struct CompletionView: View {
    @State private var scale: CGFloat = 0.5
    @State private var countdown: Int = 5

    var body: some View {
        ZStack {
            Color.green.opacity(0.1).ignoresSafeArea()

            VStack(spacing: 40) {
                // Animated checkmark or thank you icon
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 150, height: 150)

                    Image(systemName: "checkmark")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(scale)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                        scale = 1.0
                    }
                }

                VStack(spacing: 16) {
                    Text("Thank You!")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.green)

                    Text("Your note has been submitted")
                        .font(.title2)
                        .foregroundColor(.gray)

                    Text("Ready for the next guest in \(countdown) seconds...")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                }
            }
        }
        .onAppear {
            startCountdown()
        }
    }

    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            countdown -= 1
            if countdown <= 0 {
                timer.invalidate()
            }
        }
    }
}
