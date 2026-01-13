//
//  readView.swift
//  Haptille
//
//  Created by Madhan on 23/12/25.
//

import SwiftUI
import VisionKit
import UIKit
import AVFoundation

struct readView: View {
    @State private var inputText = ""
    @State private var showScanner = false
    @State private var isPlaying = false
    @State private var playTask: Task<Void, Never>?
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.openURL) private var openURL
    @State private var cameraAuthorization = AVCaptureDevice.authorizationStatus(for: .video)
    private let logic = HaptilleLogic.shared

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

            if cameraAuthorization == .denied || cameraAuthorization == .restricted {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Camera access is off.")
                        .font(.footnote)
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                    .font(.footnote)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .fullScreenCover(isPresented: $showScanner) {
            textScannerView(scannedText: $inputText, isPresented: $showScanner)
        }
        .onAppear {
            cameraAuthorization = AVCaptureDevice.authorizationStatus(for: .video)
            PermissionGate.runOnce(key: "hasRequestedReadCameraPermission") {
                AVCaptureDevice.requestAccess(for: .video) { _ in
                    DispatchQueue.main.async {
                        cameraAuthorization = AVCaptureDevice.authorizationStatus(for: .video)
                    }
                }
            }
        }
        .onDisappear {
            stopPlayback()
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
        playTask = Task {
            await logic.play(text: text)
            await MainActor.run {
                isPlaying = false
            }
        }
    }

    private func stopPlayback() {
        playTask?.cancel()
        playTask = nil
        Task {
            await logic.stop()
        }
        isPlaying = false
    }
}

#Preview {
    readView()
}
