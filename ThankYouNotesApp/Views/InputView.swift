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
                VStack(spacing: 20) {
                    Text("Who would you like to thank?")
                        .font(.system(size: 64, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)

                    Text("Step 1 of 3")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                }
                .padding(.top, 100)

                Spacer()

                // Input fields
                VStack(spacing: 50) {
                    // Recipient field (larger, emphasized)
                    VStack(alignment: .leading, spacing: 20) {
                        Text("To:")
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundColor(.orange)

                        TextField("Recipient Name", text: $sessionManager.drawingState.recipient)
                            .font(.system(size: 56, weight: .medium))
                            .padding(30)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.orange.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.orange.opacity(0.3), lineWidth: 3)
                                    )
                            )
                            .focused($focusedField, equals: .recipient)
                    }

                    // Sender field
                    VStack(alignment: .leading, spacing: 20) {
                        Text("From:")
                            .font(.system(size: 42, weight: .semibold))
                            .foregroundColor(.gray)

                        TextField("Your Name", text: $sessionManager.drawingState.sender)
                            .font(.system(size: 48))
                            .padding(30)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.gray.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                                    )
                            )
                            .focused($focusedField, equals: .sender)
                    }
                }
                .padding(.horizontal, 80)

                // Error message
                if let error = sessionManager.lastError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.headline)
                }

                Spacer()

                // Navigation buttons
                HStack(spacing: 40) {
                    Button(action: {
                        sessionManager.triggerHaptic(.light)
                        sessionManager.currentState = .welcome
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 32))
                            Text("Back")
                                .font(.system(size: 40))
                        }
                        .foregroundColor(.gray)
                        .padding(.horizontal, 60)
                        .padding(.vertical, 30)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(20)
                    }

                    Button(action: {
                        sessionManager.triggerHaptic(.medium)
                        focusedField = nil
                        sessionManager.proceedToTemplateSelection()
                    }) {
                        HStack(spacing: 15) {
                            Text("Next")
                                .font(.system(size: 44, weight: .bold))
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 44))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 35)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.4, blue: 0.3),
                                    Color(red: 1.0, green: 0.6, blue: 0.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: .orange.opacity(0.4), radius: 15, y: 10)
                        .opacity(sessionManager.drawingState.recipient.isEmpty ? 0.5 : 1.0)
                    }
                    .disabled(sessionManager.drawingState.recipient.isEmpty)
                }
                .padding(.horizontal, 80)
                .padding(.bottom, 80)
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
