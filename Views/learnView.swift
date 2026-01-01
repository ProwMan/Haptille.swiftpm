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

    @State private var currentIndex = 0
    @State private var isPlaying = false

    private var currentCharacter: Character {
        characters[currentIndex]
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

            learnCharacterCard(
                character: currentCharacter,
                index: currentIndex + 1,
                total: characters.count
            )

            learnControls(
                isPlaying: isPlaying,
                isFirst: isFirst,
                isLast: isLast,
                onPrevious: moveToPrevious,
                onPlay: playCurrentCharacter,
                onNext: moveToNext
            )

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
