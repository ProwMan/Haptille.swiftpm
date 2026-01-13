import Foundation

struct HaptilleSettingsSnapshot: Codable {
    let frequency: Double
    let dotDuration: Double
    let shortGap: Double
    let mediumGap: Double
    let longGap: Double
    let alphabet: [String: [HaptilleSymbol]]
}

@MainActor
final class HaptilleSettingsStore: ObservableObject {
    @Published var frequency: Double { didSet { persist() } }
    @Published var dotDuration: Double { didSet { persist() } }
    @Published var shortGap: Double { didSet { persist() } }
    @Published var mediumGap: Double { didSet { persist() } }
    @Published var longGap: Double { didSet { persist() } }
    @Published var alphabet: [Character: [HaptilleSymbol]] { didSet { persist() } }

    nonisolated private static let storageKey = "haptilleSettingsSnapshot"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let snapshot = Self.loadSnapshot(defaults: defaults)
        frequency = snapshot.frequency
        dotDuration = snapshot.dotDuration
        shortGap = snapshot.shortGap
        mediumGap = snapshot.mediumGap
        longGap = snapshot.longGap
        alphabet = Self.alphabet(from: snapshot)
    }

    nonisolated static func currentSnapshot() -> HaptilleSettingsSnapshot {
        loadSnapshot(defaults: .standard)
    }

    nonisolated static func alphabet(from snapshot: HaptilleSettingsSnapshot) -> [Character: [HaptilleSymbol]] {
        var output: [Character: [HaptilleSymbol]] = [:]
        for (key, pattern) in snapshot.alphabet {
            guard let char = key.first else { continue }
            output[char] = pattern
        }
        return output
    }

    nonisolated static func currentAlphabet() -> [Character: [HaptilleSymbol]] {
        alphabet(from: currentSnapshot())
    }

    nonisolated private static func defaultSnapshot() -> HaptilleSettingsSnapshot {
        let alphabet = defaultHaptilleAlphabet.reduce(into: [String: [HaptilleSymbol]]()) { result, entry in
            result[String(entry.key)] = entry.value
        }
        return HaptilleSettingsSnapshot(
            frequency: 180,
            dotDuration: 1,
            shortGap: 1,
            mediumGap: 1.5,
            longGap: 2,
            alphabet: alphabet
        )
    }

    nonisolated private static func loadSnapshot(defaults: UserDefaults) -> HaptilleSettingsSnapshot {
        guard let data = defaults.data(forKey: storageKey),
              let snapshot = try? JSONDecoder().decode(HaptilleSettingsSnapshot.self, from: data) else {
            return defaultSnapshot()
        }
        return snapshot
    }

    private func persist() {
        let snapshot = HaptilleSettingsSnapshot(
            frequency: frequency,
            dotDuration: dotDuration,
            shortGap: shortGap,
            mediumGap: mediumGap,
            longGap: longGap,
            alphabet: alphabet.reduce(into: [String: [HaptilleSymbol]]()) { result, entry in
                result[String(entry.key)] = entry.value
            }
        )
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }

    func resetToDefaults() {
        let snapshot = Self.defaultSnapshot()
        frequency = snapshot.frequency
        dotDuration = snapshot.dotDuration
        shortGap = snapshot.shortGap
        mediumGap = snapshot.mediumGap
        longGap = snapshot.longGap
        alphabet = Self.alphabet(from: snapshot)
    }
}
