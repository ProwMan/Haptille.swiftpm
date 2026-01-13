import SwiftUI

struct PatternEditorRow: View {
    let label: String
    @Binding var pattern: [HaptilleSymbol]
    let duplicateLabels: [String]
    let slotCount: Int
    let allowedSymbols: [HaptilleSymbol]
    let blankSlots: Set<Int>
    let blankSelectableSlots: Set<Int>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                Text(label)
                    .font(.headline)
                    .frame(width: 32, alignment: .leading)

                HStack(spacing: 8) {
                    ForEach(0..<slotCount, id: \.self) { index in
                        Menu {
                            if blankSelectableSlots.contains(index) {
                                Button("Blank") {
                                    setBlank(at: index)
                                }
                            }
                            ForEach(allowedSymbols, id: \.self) { symbol in
                                Button(symbol.displayName) {
                                    updateSymbol(at: index, with: symbol)
                                }
                            }
                        } label: {
                            Text(symbolLabel(at: index))
                                .font(.caption)
                                .frame(minWidth: 64)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color(.tertiarySystemFill))
                                )
                        }
                    }
                }
            }

            if !duplicateLabels.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.yellow)
                    Text("Same as \(duplicateLabels.joined(separator: ", ")).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func symbolLabel(at index: Int) -> String {
        if blankSlots.contains(index) {
            return ""
        }
        return normalizedPattern()[index].shortLabel
    }

    private func updateSymbol(at index: Int, with symbol: HaptilleSymbol) {
        var updated = normalizedPattern()
        updated[index] = symbol
        if blankSlots.contains(slotCount - 1), index != slotCount - 1 {
            updated = Array(updated.prefix(slotCount - 1))
        }
        pattern = updated
    }

    private func normalizedPattern() -> [HaptilleSymbol] {
        let fallback = allowedSymbols.contains(.shortPause)
            ? .shortPause
            : (allowedSymbols.first ?? .shortPause)
        let allowed = Set(allowedSymbols)
        var updated = pattern.map { allowed.contains($0) ? $0 : fallback }
        if updated.count < slotCount {
            updated.append(contentsOf: Array(repeating: fallback, count: slotCount - updated.count))
        } else if updated.count > slotCount {
            updated = Array(updated.prefix(slotCount))
        }
        return updated
    }

    private func setBlank(at index: Int) {
        var updated = normalizedPattern()
        if index < updated.count {
            updated = Array(updated.prefix(index))
        }
        pattern = updated
    }
}
