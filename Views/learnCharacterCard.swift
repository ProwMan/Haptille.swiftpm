//
//  learnCharacterCard.swift
//  Haptille
//
//  Created by Madhan on 23/12/25.
//

import SwiftUI

struct learnCharacterCard: View {
    let character: Character
    let index: Int
    let total: Int

    private var displayCharacter: String {
        character.isLetter
            ? String(character).uppercased()
            : String(character)
    }

    private var subtitle: String {
        "Character \(index) of \(total)"
    }

    var body: some View {
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
    }
}
