//
//  haptilleInterpreter.swift
//  Haptille
//
//  Created by Madhan on 24/12/25.
//

import Foundation

func haptilleSymbols(from text: String) -> [HaptilleSymbol] {
    var output: [HaptilleSymbol] = []
    let sentenceTerminators: Set<Character> = [".", "!", "?"]
    let softPunctuation: Set<Character> = [",", ";", ":"]

    for char in text.lowercased() {
        if char == " " {
            output.append(.longPause)
            continue
        }

        if let word = numberWords[char] {
            for (index, letter) in word.enumerated() {
                output.append(contentsOf: haptilleAlphabet[letter] ?? [])
                if index < word.count - 1 {
                    output.append(.shortPause)
                }
            }
            output.append(.longPause)
            continue
        }

        let symbols = haptilleAlphabet[char] ?? []
        if !symbols.isEmpty {
            output.append(contentsOf: symbols)
            if sentenceTerminators.contains(char) {
                output.append(.longPause)
            } else if softPunctuation.contains(char) {
                output.append(.shortPause)
            } else {
                output.append(.shortPause)
            }
        }
    }

    return output
}
