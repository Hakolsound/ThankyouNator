import SwiftUI

struct TemplateSelectionView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var selectedTemplate: TemplateTheme?

    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Text("Choose a Template")
                        .font(.system(size: 42, weight: .semibold))

                    Text("Step 2 of 3")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                .padding(.top, 60)

                // Template grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(TemplateTheme.allCases, id: \.self) { template in
                            TemplateCard(
                                template: template,
                                isSelected: selectedTemplate == template
                            )
                            .onTapGesture {
                                sessionManager.triggerHaptic(.light)
                                selectedTemplate = template
                            }
                        }
                    }
                    .padding(.horizontal, 60)
                }

                // Navigation buttons
                HStack(spacing: 30) {
                    Button(action: {
                        sessionManager.triggerHaptic(.light)
                        sessionManager.currentState = .input
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
                        if let template = selectedTemplate {
                            sessionManager.triggerHaptic(.medium)
                            sessionManager.selectTemplate(template)
                        }
                    }) {
                        HStack {
                            Image(systemName: "pencil.tip.crop.circle.fill")
                            Text("Start Drawing")
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
                        .opacity(selectedTemplate == nil ? 0.5 : 1.0)
                    }
                    .disabled(selectedTemplate == nil)
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 60)
            }
        }
    }
}

// MARK: - Template Card
struct TemplateCard: View {
    let template: TemplateTheme
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 12) {
            // Preview rectangle
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hexString: template.backgroundColor))
                    .aspectRatio(0.75, contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 4 : 2)
                    )
                    .shadow(color: isSelected ? .blue.opacity(0.3) : .clear, radius: 8)

                // Template-specific preview elements
                templatePreview
            }

            // Template name
            Text(template.displayName)
                .font(.title3)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .blue : .primary)
        }
    }

    @ViewBuilder
    private var templatePreview: some View {
        switch template {
        case .stickyNote:
            VStack(spacing: 8) {
                ForEach(0..<5) { _ in
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 1)
                        .padding(.horizontal, 10)
                }
            }
            .frame(maxHeight: .infinity, alignment: .center)

        case .confetti:
            ZStack {
                ForEach(0..<15, id: \.self) { _ in
                    Circle()
                        .fill([Color.red, .blue, .yellow, .green, .pink].randomElement()!)
                        .frame(width: CGFloat.random(in: 4...10))
                        .offset(
                            x: CGFloat.random(in: -60...60),
                            y: CGFloat.random(in: -80...80)
                        )
                }
            }

        case .heartBorder:
            VStack {
                HStack(spacing: 10) {
                    ForEach(0..<5) { _ in
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink.opacity(0.3))
                            .font(.caption)
                    }
                }
                .padding(.top, 10)
                Spacer()
                HStack(spacing: 10) {
                    ForEach(0..<5) { _ in
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink.opacity(0.3))
                            .font(.caption)
                    }
                }
                .padding(.bottom, 10)
            }

        default:
            EmptyView()
        }
    }
}

#Preview {
    TemplateSelectionView()
        .environmentObject(SessionManager())
}
