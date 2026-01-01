//
//  learnView.swift
//  Haptille
//
//  Created by Madhan on 23/12/25.
//

import SwiftUI

struct learnView: View {
    private let logic = HaptilleLogic()
    private let characters: [Character] = {
        let letters = haptilleAlphabet.keys.filter { $0.isLetter }
        let punctuation = haptilleAlphabet.keys.filter { !$0.isLetter && !$0.isNumber && $0 != " " }
        return letters.sorted() + punctuation.sorted()
    }()
    private let accentColor = Color(red: 0.839, green: 0.620, blue: 0.180)

    @State private var currentIndex = 0
    @State private var isPlaying = false

    private var currentCharacter: Character {
        characters[currentIndex]
    }

    private var displayCharacter: String {
        switch currentCharacter {
        default:
            if currentCharacter.isLetter {
                return String(currentCharacter).uppercased()
            } else {
                return String(currentCharacter)
            }
        }
    }

    private var subtitle: String {
        "Character \(currentIndex + 1) of \(characters.count)"
    }

    private var isFirst: Bool {
        currentIndex == 0
    }

    private var isLast: Bool {
        currentIndex == characters.count - 1
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Learn Haptille")
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Play the current character to feel its pattern, then step through the rest at your pace.")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                Text(displayCharacter)
                    .font(.system(size: 96, weight: .bold, design: .rounded))
                    .frame(width: 220, height: 180)
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                    )

                Text(subtitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                Button {
                    moveToPrevious()
                } label: {
                    Label("Previous", systemImage: "arrow.left")
                }
                .buttonStyle(.bordered)
                .disabled(isPlaying || isFirst)
                .tint(Color(red: 0.839, green: 0.620, blue: 0.180))

                Button {
                    playCurrentCharacter()
                } label: {
                    Label(isPlaying ? "Playing" : "Play", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isPlaying)
                .tint(Color(red: 0.839, green: 0.620, blue: 0.180))

                Button {
                    moveToNext()
                } label: {
                    Label(isLast ? "Done" : "Next", systemImage: isLast ? "checkmark.circle" : "arrow.right")
                }
                .buttonStyle(.bordered)
                .disabled(isPlaying)
                .tint(Color(red: 0.839, green: 0.620, blue: 0.180))
            }
            .controlSize(.large)

            Spacer()
        }
        .padding()
    }

    private func playCurrentCharacter() {
        guard !isPlaying else { return }
        isPlaying = true
        let characterString = String(currentCharacter)

        Task {
            await logic.play(text: characterString)
            await MainActor.run {
                isPlaying = false
            }
        }
    }

    private func moveToNext() {
        guard !isLast else { return }
        currentIndex += 1
    }

    private func moveToPrevious() {
        guard !isFirst else { return }
        currentIndex -= 1
    }
}

#Preview {
    learnView()
}
