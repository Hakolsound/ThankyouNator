import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    @Binding var isPresented: Bool
    let sessionId: String
    let uploadURL: String
    @State private var isWaitingForUpload = false

    var body: some View {
        GeometryReader { geometry in
            let isLargeScreen = geometry.size.width > 1000
            let toolbarWidth: CGFloat = isLargeScreen ? 180 : 140
            let availableWidth = geometry.size.width - toolbarWidth
            let horizontalMargin: CGFloat = isLargeScreen ? 60 : 40
            let minModalWidth: CGFloat = isLargeScreen ? 600 : 500
            let modalWidth: CGFloat = max(minModalWidth, availableWidth - (horizontalMargin * 2))

            HStack(spacing: 0) {
                Spacer()
                    .frame(width: toolbarWidth)

                Spacer()
                    .frame(width: horizontalMargin)

                VStack(spacing: isLargeScreen ? 24 : 20) {
                    // Close button only
                    HStack {
                        Spacer()

                        Button(action: {
                            isPresented = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: isLargeScreen ? 32 : 28))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, isLargeScreen ? 24 : 20)
                    .padding(.top, 10)

                    // Cool Chrome-style instructions
                    VStack(spacing: isLargeScreen ? 16 : 12) {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: isLargeScreen ? 32 : 28, height: isLargeScreen ? 32 : 28)
                                .overlay(
                                    Text("1")
                                        .font(.system(size: isLargeScreen ? 16 : 14, weight: .bold))
                                        .foregroundColor(.white)
                                )

                            Text("Scan the code with your phone")
                                .font(.system(size: isLargeScreen ? 20 : 18, weight: .medium))
                                .foregroundColor(.primary)

                            Spacer()
                        }

                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: isLargeScreen ? 32 : 28, height: isLargeScreen ? 32 : 28)
                                .overlay(
                                    Text("2")
                                        .font(.system(size: isLargeScreen ? 16 : 14, weight: .bold))
                                        .foregroundColor(.white)
                                )

                            Text("Upload an epic photo")
                                .font(.system(size: isLargeScreen ? 20 : 18, weight: .medium))
                                .foregroundColor(.primary)

                            Spacer()
                        }
                    }
                    .padding(.horizontal, isLargeScreen ? 24 : 20)

                    // QR Code
                    ZStack {
                        if let qrImage = generateQRCode(from: uploadURL) {
                            Image(uiImage: qrImage)
                                .interpolation(.none)
                                .resizable()
                                .frame(width: isLargeScreen ? 320 : 280, height: isLargeScreen ? 320 : 280)
                                .padding(isLargeScreen ? 24 : 20)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                                .opacity(isWaitingForUpload ? 0.3 : 1.0)
                        }

                        // Waiting indicator
                        if isWaitingForUpload {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                                Text("Waiting for photo...")
                                    .font(.system(size: isLargeScreen ? 18 : 16, weight: .medium))
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .frame(height: isLargeScreen ? 380 : 330)

                    // URL display
                    Text(uploadURL)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, isLargeScreen ? 24 : 20)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    // Close button
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Close")
                            .font(.system(size: isLargeScreen ? 20 : 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, isLargeScreen ? 16 : 14)
                            .background(Color.gray.opacity(0.7))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, isLargeScreen ? 24 : 20)
                }
                .frame(width: modalWidth)
                .padding(.vertical, isLargeScreen ? 24 : 20)
                .background(Color(white: 0.96))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 4)

                Spacer()
                    .frame(width: horizontalMargin)
            }
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
