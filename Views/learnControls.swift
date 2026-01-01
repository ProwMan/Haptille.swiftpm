//
//  learnControls.swift
//  Haptille
//
//  Created by Madhan on 23/12/25.
//

import SwiftUI

struct learnControls: View {
    let accentColor: Color = Color(red: 0.839, green: 0.620, blue: 0.180)
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
        .tint(accentColor)
    }
}
