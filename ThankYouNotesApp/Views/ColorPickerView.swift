import SwiftUI

struct ColorPickerView: View {
    @Binding var isPresented: Bool
    let onColorSelected: (Color) -> Void

    @State private var selectedHue: Double = 0.0
    @State private var selectedSaturation: Double = 0.0 // Start at center (white)
    @State private var selectedBrightness: Double = 1.0
    @State private var indicatorPosition: CGPoint = CGPoint(x: 175, y: 175) // Start at center

    var selectedColor: Color {
        Color(hue: selectedHue, saturation: selectedSaturation, brightness: selectedBrightness)
    }

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            VStack(spacing: 30) {
                VStack(spacing: 40) {
                    // Color wheel
                    ZStack {
                        // Outer color wheel
                        Circle()
                            .fill(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        .red, .yellow, .green, .cyan, .blue, Color(red: 1, green: 0, blue: 1), .red
                                    ]),
                                    center: .center,
                                    startAngle: .degrees(0),
                                    endAngle: .degrees(360)
                                )
                            )
                            .frame(width: 350, height: 350)
                            .overlay(
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            gradient: Gradient(colors: [.white, .clear]),
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: 175
                                        )
                                    )
                            )
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        updateColor(at: value.location, in: 350)
                                    }
                            )

                        // Selection indicator - positioned at touch location
                        Circle()
                            .fill(selectedColor)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                            )
                            .shadow(radius: 10)
                            .offset(x: indicatorPosition.x - 175, y: indicatorPosition.y - 175)
                    }

                    // Brightness slider
                    VStack(spacing: 15) {
                        Text("Brightness")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)

                        Slider(value: $selectedBrightness, in: 0.2...1.0)
                            .accentColor(selectedColor)
                            .frame(width: 350)
                    }

                    // Preview and confirm button
                    VStack(spacing: 20) {
                        // Color preview
                        RoundedRectangle(cornerRadius: 16)
                            .fill(selectedColor)
                            .frame(width: 350, height: 80)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white, lineWidth: 3)
                            )
                            .shadow(radius: 10)

                        // Confirm button
                        Button(action: {
                            onColorSelected(selectedColor)
                            isPresented = false
                        }) {
                            Text("Use This Color")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 350)
                                .padding(.vertical, 20)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.5, green: 0.3, blue: 1.0),
                                            Color(red: 0.8, green: 0.3, blue: 0.9)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(radius: 10)
                        }
                    }
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color(red: 0.2, green: 0.2, blue: 0.25))
                )
                .shadow(radius: 30)
            }
        }
    }

    private func updateColor(at location: CGPoint, in size: CGFloat) {
        let center = size / 2
        let dx = location.x - center
        let dy = location.y - center
        let distance = sqrt(dx * dx + dy * dy)
        let maxDistance = center

        // Clamp the indicator position to stay within the circle
        let angle = atan2(dy, dx)

        if distance > maxDistance {
            // If touch is outside circle, project it onto the edge
            let clampedX = center + cos(angle) * maxDistance
            let clampedY = center + sin(angle) * maxDistance
            indicatorPosition = CGPoint(x: clampedX, y: clampedY)
        } else {
            indicatorPosition = location
        }

        // Calculate hue from angle
        // Convert angle from -π to π to hue from 0 to 1
        // The gradient goes: red(0°), yellow(60°), green(120°), cyan(180°), blue(240°), magenta(300°), red(360°)
        // atan2 gives us: right=0°, top=90°, left=180°, bottom=-90°
        var hue = (angle / (2 * .pi))
        if hue < 0 {
            hue += 1.0
        }
        selectedHue = hue

        // Calculate saturation from distance
        selectedSaturation = min(distance / maxDistance, 1.0)
    }
}

#Preview {
    ColorPickerView(isPresented: .constant(true)) { color in
        print("Selected color: \(color)")
    }
}
