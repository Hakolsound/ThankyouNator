import SwiftUI
import PencilKit

struct PencilToolPickerView: View {
    @Binding var isPresented: Bool
    let onToolSelected: (PKInkingTool.InkType, String) -> Void

    let tools: [(type: PKInkingTool.InkType, name: String, icon: String)] = [
        (.pen, "Pen", "pencil.tip"),
        (.marker, "Marker", "highlighter"),
        (.pencil, "Pencil", "pencil"),
        (.monoline, "Mono", "scribble"),
    ]

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Small popover menu attached to the left side
            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    ForEach(tools, id: \.name) { tool in
                        Button(action: {
                            onToolSelected(tool.type, tool.name)
                            isPresented = false
                        }) {
                            VStack(spacing: 2) {
                                Image(systemName: tool.icon)
                                    .font(.system(size: 20))
                                Text(tool.name)
                                    .font(.system(size: 9))
                            }
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color(red: 0.2, green: 0.2, blue: 0.25))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.15, green: 0.15, blue: 0.2))
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                )

                // Arrow pointing to the button
                Triangle()
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.2))
                    .frame(width: 12, height: 12)
                    .rotationEffect(.degrees(-90))
                    .offset(x: -1, y: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.leading, 180) // Position right next to the pencil button
            .padding(.top, 120) // Centered vertically near the pen tool button
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            isPresented = false
        }
    }
}

// Helper shape for the arrow
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    PencilToolPickerView(isPresented: .constant(true)) { type, name in
        print("Selected: \(name)")
    }
}
