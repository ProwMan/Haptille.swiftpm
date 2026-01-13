import SwiftUI

struct LearnView: View {
    @EnvironmentObject private var haptilleSettings: HaptilleSettingsStore
    private let logic = HaptilleLogic.shared

    private var items: [LearnItem] {
        let keys = haptilleSettings.alphabet.keys
        let letters = keys.filter { $0.isLetter }
        let punctuation = keys.filter { !$0.isLetter && !$0.isNumber && $0 != " " }
        let letterItems = letters.sorted().map { LearnItem.character($0) }
        let punctuationItems = punctuation.sorted().map { LearnItem.character($0) }
        return letterItems + punctuationItems + [.character(" "), .mediumPause]
    }

    @State private var currentIndex = 0
    @State private var isPlaying = false
    @State private var playTask: Task<Void, Never>?

    private var currentItem: LearnItem {
        items[currentIndex]
    }

    private var isFirst: Bool {
        currentIndex == 0
    }

    private var isLast: Bool {
        currentIndex == items.count - 1
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Learn Haptille")
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Play the current character to feel its pattern, then step through the rest at your pace.")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            LearnCharacterCard(
                item: currentItem,
                index: currentIndex + 1,
                total: items.count,
                pattern: pattern(for: currentItem)
            )

            LearnControls(
                isPlaying: isPlaying,
                isFirst: isFirst,
                isLast: isLast,
                onPrevious: moveToPrevious,
                onPlay: playCurrentItem,
                onNext: moveToNext
            )

            Spacer()
        }
        .padding()
        .onDisappear {
            stopPlayback()
        }
    }

    private func pattern(for item: LearnItem) -> [HaptilleSymbol] {
        switch item {
        case .mediumPause:
            return [.mediumPause]
        case .character(let character):
            if character == " " {
                return [.longPause]
            }

            let base = haptilleSettings.alphabet[character] ?? []

            if character.isLetter {
                return base
            }

            if base.first == .shortPause {
                return Array(base.dropFirst())
            }

            return base
        }
    }

    private func playCurrentItem() {
        guard !isPlaying else { return }
        isPlaying = true

        playTask = Task {
            switch currentItem {
            case .mediumPause:
                await logic.play(symbols: [.mediumPause])
            case .character(let character):
                await logic.play(text: String(character))
            }
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
    LearnView()
        .environmentObject(HaptilleSettingsStore())
}
