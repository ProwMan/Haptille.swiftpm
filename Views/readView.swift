//
//  readView.swift
//  Haptille
//
//  Created by Madhan on 23/12/25.
//

import SwiftUI
import VisionKit
import UIKit

struct readView: View {
    @State private var inputText = ""
    @State private var showScanner = false
    @State private var isPlaying = false
    @FocusState private var isTextFieldFocused: Bool
    private let logic = HaptilleLogic()

    private var hasText: Bool { !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private var canScan: Bool { DataScannerViewController.isSupported && DataScannerViewController.isAvailable }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Read")
                .font(.title2)

            TextField("Type something to feel", text: $inputText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .focused($isTextFieldFocused)

            readActions(
                canScan: canScan,
                hasText: hasText,
                isPlaying: isPlaying,
                onPaste: pasteFromClipboard,
                onScan: startScanner,
                onDone: playHaptille
            )

            Spacer()
        }
        .padding()
        .fullScreenCover(isPresented: $showScanner) {
            textScannerView(scannedText: $inputText, isPresented: $showScanner)
        }
    }

    private func pasteFromClipboard() {
        let pasteboard = UIPasteboard.general
        guard pasteboard.hasStrings, !pasteboard.hasImages else { return }
        if let pastedText = pasteboard.string {
            inputText = pastedText
        }
    }

    private func startScanner() {
        guard canScan else { return }
        isTextFieldFocused = false
        showScanner = true
    }

    private func playHaptille() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        guard !isPlaying else { return }
        isPlaying = true
        isTextFieldFocused = false
        Task {
            await logic.play(text: text)
            await MainActor.run {
                isPlaying = false
            }
        }
    }
}

#Preview {
    readView()
}
