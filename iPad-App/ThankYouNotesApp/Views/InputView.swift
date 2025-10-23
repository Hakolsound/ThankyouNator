import SwiftUI

struct InputView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @FocusState private var focusedField: Field?

    enum Field {
        case recipient, sender
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 40) {
                // Header
                VStack(spacing: 10) {
                    Text("Who would you like to thank?")
                        .font(.system(size: 42, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)

                    Text("Step 1 of 3")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding(.top, 80)

                Spacer()

                // Input fields
                VStack(spacing: 30) {
                    // Recipient field (larger, emphasized)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("To:")
                            .font(.title2)
                            .foregroundColor(.gray)

                        TextField("Recipient Name", text: $sessionManager.drawingState.recipient)
                            .font(.system(size: 36, weight: .medium))
                            .padding(20)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .focused($focusedField, equals: .recipient)
                    }

                    // Sender field (smaller)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("From:")
                            .font(.title3)
                            .foregroundColor(.gray)

                        TextField("Your Name", text: $sessionManager.drawingState.sender)
                            .font(.system(size: 28))
                            .padding(20)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .focused($focusedField, equals: .sender)
                    }
                }
                .padding(.horizontal, 60)

                // Error message
                if let error = sessionManager.lastError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.headline)
                }

                Spacer()

                // Navigation buttons
                HStack(spacing: 30) {
                    Button(action: {
                        sessionManager.triggerHaptic(.light)
                        sessionManager.currentState = .welcome
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                    }

                    Button(action: {
                        sessionManager.triggerHaptic(.medium)
                        focusedField = nil
                        sessionManager.proceedToTemplateSelection()
                    }) {
                        HStack {
                            Text("Next")
                            Image(systemName: "chevron.right")
                        }
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .opacity(sessionManager.drawingState.recipient.isEmpty ? 0.5 : 1.0)
                    }
                    .disabled(sessionManager.drawingState.recipient.isEmpty)
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            focusedField = .recipient
        }
    }
}

#Preview {
    InputView()
        .environmentObject(SessionManager())
}
