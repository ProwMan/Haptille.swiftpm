//
//  readActions.swift
//  Haptille
//
//  Created by Madhan on 23/12/25.
//

import SwiftUI

struct readActions: View {
    let canScan: Bool
    let hasText: Bool
    let isPlaying: Bool
    let onPaste: () -> Void
    let onScan: () -> Void
    let onDone: () -> Void

    private let pasteColor = Color(red: 0.357, green: 0.702, blue: 0.941)
    private let scanColor = Color(red: 0.208, green: 0.596, blue: 0.859)
    private let doneColor = Color(red: 0.0, green: 0.478, blue: 1.0)

    var body: some View {
        HStack(spacing: 20) {
            Button("Paste copied text", action: onPaste)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .tint(pasteColor)

            Button("Scan for text", action: onScan)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .tint(scanColor)
                .disabled(!canScan)

            Button(isPlaying ? "Playing" : "Done", action: onDone)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .tint(doneColor)
                .disabled(!hasText || isPlaying)
        }
        .controlSize(.large)
        .font(.headline)
    }
}
