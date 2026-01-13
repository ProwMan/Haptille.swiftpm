import SwiftUI

struct LearnControls: View {
    let isPlaying: Bool
    let isFirst: Bool
    let isLast: Bool
    let onPrevious: () -> Void
    let onPlay: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button("Previous", systemImage: "arrow.left", action: onPrevious)
                .buttonStyle(.bordered)
                .disabled(isPlaying || isFirst)

            Button(isPlaying ? "Playing" : "Play", systemImage: "play.fill", action: onPlay)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .disabled(isPlaying)

            Button(isLast ? "Done" : "Next", systemImage: isLast ? "checkmark.circle" : "arrow.right", action: onNext)
                .buttonStyle(.bordered)
                .disabled(isPlaying)
        }
        .controlSize(.large)
        .tint(AppColors.learn)
    }
}
