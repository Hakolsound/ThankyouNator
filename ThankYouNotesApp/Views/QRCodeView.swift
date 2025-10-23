import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    @Binding var isPresented: Bool
    let sessionId: String
    let uploadURL: String
    @State private var isWaitingForUpload = false

    var body: some View {
        ZStack {
        VStack(spacing: 30) {
            // Header
            HStack {
                Text("📸 Add a Photo")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.orange)

                Spacer()

                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 40)

            // Instructions
            VStack(spacing: 15) {
                Text("Scan with your phone")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.primary)

                Text("Take a photo and add it to your note")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)

            // QR Code
            ZStack {
                if let qrImage = generateQRCode(from: uploadURL) {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .frame(width: 400, height: 400)
                        .background(Color.white)
                        .cornerRadius(24)
                        .shadow(color: .orange.opacity(0.3), radius: 20, y: 10)
                        .padding(40)
                        .opacity(isWaitingForUpload ? 0.3 : 1.0)
                }

                // Waiting for upload indicator
                if isWaitingForUpload {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(2.0)
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.8, green: 0.3, blue: 0.9)))
                        Text("Waiting for photo...")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(red: 0.8, green: 0.3, blue: 0.9))
                    }
                    .frame(width: 400, height: 400)
                }
            }
            .onTapGesture {
                // Toggle waiting state for visual feedback
                if !isWaitingForUpload {
                    withAnimation {
                        isWaitingForUpload = true
                    }
                    // Reset after 3 seconds if no upload
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            isWaitingForUpload = false
                        }
                    }
                }
            }

            // URL display (for debugging)
            Text(uploadURL)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
                .lineLimit(2)
                .truncationMode(.middle)

            Spacer()

            // Close button
            Button(action: {
                isPresented = false
            }) {
                Text("Close")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 25)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(20)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(
            LinearGradient(
                colors: [Color.white, Color(red: 0.95, green: 0.92, blue: 0.98)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(24)
        }
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()

        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)

            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return nil
    }
}
