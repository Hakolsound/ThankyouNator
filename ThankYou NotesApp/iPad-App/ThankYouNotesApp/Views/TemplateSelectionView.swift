import SwiftUI

struct TemplateSelectionView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var selectedTemplate: TemplateTheme?

    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 40) {
                // Header
                VStack(spacing: 20) {
                    Text("Choose a Template")
                        .font(.system(size: 64, weight: .bold))

                    Text("Step 2 of 3")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                }
                .padding(.top, 100)

                // Template grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 15) {
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
                    .padding(.horizontal, 40)
                }

                // Navigation buttons
                HStack(spacing: 40) {
                    Button(action: {
                        sessionManager.triggerHaptic(.light)
                        sessionManager.currentState = .input
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
                        if let template = selectedTemplate {
                            sessionManager.triggerHaptic(.medium)
                            sessionManager.selectTemplate(template)
                        }
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "pencil.tip.crop.circle.fill")
                                .font(.system(size: 44))
                            Text("Start Drawing")
                                .font(.system(size: 44, weight: .bold))
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
                        .opacity(selectedTemplate == nil ? 0.5 : 1.0)
                    }
                    .disabled(selectedTemplate == nil)
                }
                .padding(.horizontal, 80)
                .padding(.bottom, 80)
            }
        }
    }
}

// MARK: - Template Card
struct TemplateCard: View {
    let template: TemplateTheme
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            // Preview rectangle - much smaller
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hexString: template.backgroundColor))
                    .aspectRatio(0.75, contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Color(red: 1.0, green: 0.5, blue: 0.0) : Color.gray.opacity(0.3), lineWidth: isSelected ? 3 : 1.5)
                    )
                    .shadow(color: isSelected ? .orange.opacity(0.5) : .clear, radius: 8)

                // Template-specific preview elements
                templatePreview
            }

            // Template name - smaller
            Text(template.displayName)
                .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? Color(red: 1.0, green: 0.5, blue: 0.0) : .primary)
                .lineLimit(1)
        }
    }

    @ViewBuilder
    private var templatePreview: some View {
        switch template {
        // Light themes
        case .blank:
            EmptyView()

        case .stickyNote:
            VStack(spacing: 4) {
                ForEach(0..<3) { _ in
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 0.5)
                        .padding(.horizontal, 8)
                }
            }

        case .watercolor:
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .offset(x: -15, y: -10)
                Circle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: 35, height: 35)
                    .offset(x: 10, y: 15)
            }

        case .confetti:
            ZStack {
                ForEach(0..<8, id: \.self) { i in
                    Circle()
                        .fill([Color.red, .blue, .yellow, .green, .pink][i % 5])
                        .frame(width: 3, height: 3)
                        .offset(
                            x: CGFloat.random(in: -25...25),
                            y: CGFloat.random(in: -35...35)
                        )
                }
            }

        case .heartBorder:
            VStack {
                HStack(spacing: 4) {
                    ForEach(0..<3) { _ in
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink.opacity(0.3))
                            .font(.system(size: 8))
                    }
                }
                .padding(.top, 6)
                Spacer()
            }

        case .minimalist:
            VStack {
                Rectangle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .frame(width: 50, height: 30)
            }

        case .gradient:
            LinearGradient(
                colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))

        case .floral:
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: "leaf.fill")
                        .foregroundColor(.orange.opacity(0.2))
                        .font(.system(size: 10))
                        .rotationEffect(.degrees(Double(i) * 45))
                }
            }

        case .sunset:
            LinearGradient(
                colors: [Color.orange.opacity(0.4), Color.pink.opacity(0.3), Color.purple.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))

        case .pastelRainbow:
            HStack(spacing: 2) {
                ForEach([Color.red, .orange, .yellow, .green, .blue, .purple], id: \.self) { color in
                    Rectangle()
                        .fill(color.opacity(0.2))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))

        case .craft:
            ZStack {
                Rectangle()
                    .stroke(Color.brown.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                    .frame(width: 50, height: 40)
            }

        case .vintage:
            ZStack {
                Circle()
                    .stroke(Color.brown.opacity(0.3), lineWidth: 1)
                    .frame(width: 40)
                Rectangle()
                    .fill(Color.brown.opacity(0.1))
                    .frame(width: 30, height: 2)
            }

        // Dark themes
        case .midnight:
            ZStack {
                ForEach(0..<5, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 2, height: 2)
                        .offset(
                            x: CGFloat.random(in: -30...30),
                            y: CGFloat.random(in: -40...40)
                        )
                }
            }

        case .neonGlow:
            ZStack {
                Circle()
                    .stroke(Color.cyan, lineWidth: 1.5)
                    .frame(width: 25)
                    .shadow(color: .cyan, radius: 4)
                Circle()
                    .stroke(Color.pink, lineWidth: 1.5)
                    .frame(width: 40)
                    .shadow(color: .pink, radius: 4)
            }

        case .deepSpace:
            ZStack {
                ForEach(0..<6, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 1.5, height: 1.5)
                        .offset(
                            x: CGFloat.random(in: -30...30),
                            y: CGFloat.random(in: -40...40)
                        )
                }
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 20)
            }

        case .darkForest:
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: "leaf.fill")
                        .foregroundColor(.green.opacity(0.4))
                        .font(.system(size: 12))
                        .offset(x: CGFloat(i - 1) * 15, y: CGFloat(i) * 8)
                }
            }

        case .charcoal:
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 50, height: 40)
                .overlay(
                    Rectangle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )

        case .galaxy:
            ZStack {
                LinearGradient(
                    colors: [Color.purple.opacity(0.4), Color.blue.opacity(0.3), Color.pink.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                ForEach(0..<8, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.7))
                        .frame(width: 1.5)
                        .offset(
                            x: CGFloat.random(in: -30...30),
                            y: CGFloat.random(in: -40...40)
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))

        case .darkGradient:
            LinearGradient(
                colors: [Color.purple.opacity(0.5), Color.black.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))

        case .moody:
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.3))
                    .frame(width: 35)
                    .blur(radius: 8)
            }

        case .darkConfetti:
            ZStack {
                ForEach(0..<8, id: \.self) { i in
                    Circle()
                        .fill([Color.cyan, .pink, .yellow, .green][i % 4])
                        .frame(width: 3)
                        .offset(
                            x: CGFloat.random(in: -25...25),
                            y: CGFloat.random(in: -35...35)
                        )
                }
            }

        case .blackboard:
            ZStack {
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 40, height: 3)
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 35, height: 3)
                    .offset(y: 10)
            }

        case .nightSky:
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.7))
                    .frame(width: 12)
                    .offset(x: -20, y: -15)
                ForEach(0..<4, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 2)
                        .offset(
                            x: CGFloat.random(in: -20...20),
                            y: CGFloat.random(in: -25...25)
                        )
                }
            }

        case .cyberpunk:
            ZStack {
                Rectangle()
                    .fill(Color.cyan.opacity(0.3))
                    .frame(width: 40, height: 2)
                    .offset(y: -10)
                Rectangle()
                    .fill(Color.pink.opacity(0.3))
                    .frame(width: 35, height: 2)
                Rectangle()
                    .fill(Color.yellow.opacity(0.3))
                    .frame(width: 30, height: 2)
                    .offset(y: 10)
            }
        }
    }
}

#Preview {
    TemplateSelectionView()
        .environmentObject(SessionManager())
}
