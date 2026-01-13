import SwiftUI

extension SettingsView {
    var letters: [Character] {
        settings.alphabet.keys
            .filter { $0.isLetter }
            .sorted { String($0) < String($1) }
    }

    var punctuation: [Character] {
        settings.alphabet.keys
            .filter { !$0.isLetter && !$0.isNumber }
            .sorted { String($0) < String($1) }
    }

    func patternList(for characters: [Character]) -> some View {
        let entries = Array(characters.enumerated())
        return LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(entries, id: \.element) { index, character in
                PatternEditorRow(
                    label: displayLabel(for: character),
                    pattern: patternBinding(for: character),
                    duplicateLabels: duplicateLabels(for: character),
                    slotCount: slotCount(for: character),
                    allowedSymbols: allowedSymbols(for: character),
                    blankSlots: blankSlots(for: character),
                    blankSelectableSlots: blankSelectableSlots(for: character)
                )

                if index < entries.count - 1 {
                    Divider()
                }
            }
        }
    }

    private var alphabetSlotCount: Int { 4 }
    private var punctuationSlotCount: Int { 4 }
    private var alphabetAllowedSymbols: [HaptilleSymbol] { [.strong, .weak, .shortPause] }
    private var punctuationAllowedSymbols: [HaptilleSymbol] { HaptilleSymbol.allCases }

    private var duplicateLookup: [Character: [Character]] {
        var grouped: [String: [Character]] = [:]
        for character in settings.alphabet.keys {
            let pattern = normalizedPattern(for: character)
            let key = pattern.map(\.rawValue).joined(separator: "|")
            grouped[key, default: []].append(character)
        }

        var duplicates: [Character: [Character]] = [:]
        for characters in grouped.values where characters.count > 1 {
            let sorted = characters.sorted { String($0) < String($1) }
            for character in sorted {
                duplicates[character] = sorted.filter { $0 != character }
            }
        }
        return duplicates
    }

    private func patternBinding(for character: Character) -> Binding<[HaptilleSymbol]> {
        let slotCount = slotCount(for: character)
        let allowedSymbols = allowedSymbols(for: character)
        let allowsTrailingBlank = allowsTrailingBlank(for: character)
        return Binding(
            get: {
                let base = settings.alphabet[character]
                    ?? defaultHaptilleAlphabet[character]
                    ?? [.weak, .shortPause, .shortPause]
                return normalizedPattern(
                    base,
                    slotCount: slotCount,
                    allowedSymbols: allowedSymbols,
                    padToSlotCount: true
                )
            },
            set: { newValue in
                settings.alphabet[character] = normalizedPattern(
                    newValue,
                    slotCount: slotCount,
                    allowedSymbols: allowedSymbols,
                    padToSlotCount: !allowsTrailingBlank
                )
            }
        )
    }

    private func normalizedPattern(_ pattern: [HaptilleSymbol],
                                   slotCount: Int,
                                   allowedSymbols: [HaptilleSymbol],
                                   padToSlotCount: Bool) -> [HaptilleSymbol] {
        let fallback = allowedSymbols.contains(.shortPause)
            ? .shortPause
            : (allowedSymbols.first ?? .shortPause)
        let allowed = Set(allowedSymbols)
        var updated = pattern.map { allowed.contains($0) ? $0 : fallback }
        if updated.count > slotCount {
            updated = Array(updated.prefix(slotCount))
        } else if padToSlotCount, updated.count < slotCount {
            updated.append(contentsOf: Array(repeating: fallback, count: slotCount - updated.count))
        }
        return updated
    }

    private func normalizedPattern(for character: Character) -> [HaptilleSymbol] {
        let base = settings.alphabet[character]
            ?? defaultHaptilleAlphabet[character]
            ?? [.weak, .shortPause, .shortPause]
        let allowsTrailingBlank = allowsTrailingBlank(for: character)
        return normalizedPattern(
            base,
            slotCount: slotCount(for: character),
            allowedSymbols: allowedSymbols(for: character),
            padToSlotCount: !allowsTrailingBlank
        )
    }

    private func slotCount(for character: Character) -> Int {
        character.isLetter ? alphabetSlotCount : punctuationSlotCount
    }

    private func allowedSymbols(for character: Character) -> [HaptilleSymbol] {
        character.isLetter ? alphabetAllowedSymbols : punctuationAllowedSymbols
    }

    private func duplicateLabels(for character: Character) -> [String] {
        guard let duplicates = duplicateLookup[character] else { return [] }
        return duplicates.map { displayLabel(for: $0) }
    }

    private func displayLabel(for character: Character) -> String {
        character.isLetter ? String(character).uppercased() : String(character)
    }

    private func blankSlots(for character: Character) -> Set<Int> {
        guard character.isLetter else { return [] }
        let base = settings.alphabet[character]
            ?? defaultHaptilleAlphabet[character]
            ?? []
        let slotCount = slotCount(for: character)
        guard base.count < slotCount else { return [] }
        return Set(base.count..<slotCount)
    }

    private func blankSelectableSlots(for character: Character) -> Set<Int> {
        character.isLetter ? [alphabetSlotCount - 1] : []
    }

    private func allowsTrailingBlank(for character: Character) -> Bool {
        character.isLetter
    }
}
