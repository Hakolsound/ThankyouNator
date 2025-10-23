import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 50) {
                Spacer()

                // App branding
                VStack(spacing: 20) {
                    Image(systemName: "envelope.open.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.blue)

                    Text("Thank You Notes")
                        .font(.system(size: 56, weight: .bold))
                        .multilineTextAlignment(.center)

                    Text("Create and share your gratitude")
                        .font(.title2)
                        .foregroundColor(.gray)
                }

                Spacer()

                // Main action button
                Button(action: {
                    sessionManager.triggerHaptic(.light)
                    sessionManager.startNewNote()
                }) {
                    HStack(spacing: 15) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                        Text("Start New Thank You Note")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal, 60)

                Spacer()
                    .frame(height: 100)
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(SessionManager())
}
