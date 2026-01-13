//
//  ConversePane.swift
//  Haptille
//
//  Created by Madhan on 23/12/25.
//

import SwiftUI

struct ConversePane: View {
    let title: String
    @ObservedObject var recognizer: speechRecognizer
    @ObservedObject var otherRecognizer: speechRecognizer
    @Binding var isDeafBlindMode: Bool
    let labelEdgePadding: CGFloat
    let onToggleRecording: () -> Void
    @Environment(\.openURL) private var openURL

    private var isSpeakDisabled: Bool {
        otherRecognizer.isRecording
    }

    private var statusMessage: String? {
        if !recognizer.isAuthorized {
            return "Enable microphone access to speak."
        }
        if otherRecognizer.isRecording {
            return "Other person is speaking."
        }
        return nil
    }

    private var showsSettingsButton: Bool {
        !recognizer.isAuthorized
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("Deafblind mode")
                            .font(.subheadline)
                        Toggle("", isOn: $isDeafBlindMode)
                            .labelsHidden()
                            .toggleStyle(.switch)
                            .accessibilityLabel("Deafblind mode")
                    }
                    Text("When on, incoming speech plays as Haptille.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Spacer()

            VStack(spacing: 20) {
                TextField("Speak to fill", text: $recognizer.transcript, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3, reservesSpace: true)
                    .disabled(true)
                    .foregroundStyle(.primary)
                    .opacity(1)
                    .padding(.horizontal, 36)

                Button(action: onToggleRecording) {
                    Text(recognizer.isRecording ? "Done" : "Speak now")
                        .font(.headline)
                        .frame(minWidth: 150)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .background(
                    Capsule()
                        .fill(AppColors.speakButton)
                )
                .overlay(
                    Capsule()
                        .stroke(AppColors.speakButtonBorder, lineWidth: 1)
                )
                .foregroundStyle(.black)
                .disabled(isSpeakDisabled)

                if let statusMessage {
                    Text(statusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if showsSettingsButton {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                    .font(.footnote)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }

            Spacer()

            Text(title)
                .font(.title2)
                .padding(.bottom, labelEdgePadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
