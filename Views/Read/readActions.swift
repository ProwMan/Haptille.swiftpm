import SwiftUI

struct ReadActions: View {
    let canScan: Bool
    let hasText: Bool
    let isPlaying: Bool
    let onPaste: () -> Void
    let onScan: () -> Void
    let onDone: () -> Void

    var body: some View {
        HStack(spacing: 20) {
            Button("Paste copied text", action: onPaste)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .tint(AppColors.paste)

            Button("Scan for text", action: onScan)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .tint(AppColors.scan)
                .disabled(!canScan)

            Button(isPlaying ? "Playing" : "Done", action: onDone)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .tint(AppColors.done)
                .disabled(!hasText || isPlaying)
        }
        .controlSize(.large)
        .font(.headline)
    }
}
