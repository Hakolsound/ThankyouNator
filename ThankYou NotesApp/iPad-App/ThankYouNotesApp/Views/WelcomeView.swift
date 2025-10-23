import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var isAnimating = false
    @State private var pulseAnimation = false

    var body: some View {
        ZStack {
            // AI-style gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.4, green: 0.2, blue: 0.9),  // Deep blue
                    Color(red: 0.8, green: 0.2, blue: 0.8),  // Magenta
                    Color(red: 1.0, green: 0.3, blue: 0.7)   // Hot pink
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Floating hearts animation
            ForEach(0..<8, id: \.self) { i in
                Text("❤️")
                    .font(.system(size: 60))
                    .opacity(0.3)
                    .offset(
                        x: CGFloat.random(in: -300...300),
                        y: isAnimating ? -1000 : 1000
                    )
                    .animation(
                        Animation.linear(duration: Double.random(in: 8...12))
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 0.5),
                        value: isAnimating
                    )
            }

            VStack(spacing: 0) {
                Spacer()

                // Giant animated button
                Button(action: {
                    sessionManager.triggerHaptic(.heavy)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        sessionManager.startNewNote()
                    }
                }) {
                    VStack(spacing: 40) {
                        // Huge emoji icon
                        Text("✍️")
                            .font(.system(size: 180))
                            .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true),
                                value: pulseAnimation
                            )

                        // Call to action
                        VStack(spacing: 20) {
                            Text("ThankYou-nator")
                                .font(.system(size: 72, weight: .bold))
                                .foregroundColor(.white)

                            Text("Click to start")
                                .font(.system(size: 72, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 700, height: 700)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.5, green: 0.3, blue: 1.0),  // Purple
                                        Color(red: 0.9, green: 0.3, blue: 0.8),  // Pink-magenta
                                        Color(red: 0.3, green: 0.5, blue: 1.0)   // Blue
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: .purple.opacity(0.6), radius: 40, x: 0, y: 20)
                    )
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                }
                .buttonStyle(PlainButtonStyle())

                Spacer()
            }
        }
        .onAppear {
            isAnimating = true
            pulseAnimation = true
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(SessionManager())
}
