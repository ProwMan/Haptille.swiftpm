import SwiftUI

struct LearnCharacterCard: View {
    let item: LearnItem
    let index: Int
    let total: Int
    let pattern: [HaptilleSymbol]

    private var displayCharacter: String {
        switch item {
        case .mediumPause:
            return "Medium pause"
        case .character(let character):
            if character == " " {
                return "Space"
            }
            return character.isLetter
                ? String(character).uppercased()
                : String(character)
        }
    }

    private var subtitle: String {
        "Character \(index) of \(total)"
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(displayCharacter)
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity, minHeight: 180)
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )

            Text(subtitle)
                .font(.headline)
                .foregroundStyle(.secondary)

            if !pattern.isEmpty {
                VStack(spacing: 8) {
                    Text("Pattern")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        ForEach(Array(pattern.enumerated()), id: \.offset) { item in
                            Chip(text: symbolLabel(for: item.element))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }

    private struct Chip: View {
        let text: String

        var body: some View {
            Text(text)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(.tertiarySystemFill))
                )
        }
    }

    private func symbolLabel(for symbol: HaptilleSymbol) -> String {
        switch symbol {
        case .strong:
            return "Strong"
        case .weak:
            return "Weak"
        case .shortPause:
            return "Short pause"
        case .mediumPause:
            return "Medium pause"
        case .longPause:
            return "Long pause"
        }
    }
}

#Preview {
    LearnCharacterCard(
        item: .character("a"),
        index: 1,
        total: 2,
        pattern: defaultHaptilleAlphabet["a"] ?? []
    )
}
