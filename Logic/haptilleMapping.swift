//
//  haptilleMapping.swift
//  Haptille
//
//  Created by Madhan on 24/12/25.
//

import Foundation

let haptilleAlphabet: [Character: [HaptilleSymbol]] = [
    "a": [.strong],
    "b": [.strong, .weak],
    "c": [.strong, .shortPause, .strong],
    "d": [.strong, .shortPause, .strong, .weak],
    "e": [.strong, .shortPause, .weak],
    "f": [.strong, .weak, .shortPause, .strong],
    "g": [.strong, .weak, .shortPause, .strong, .weak],
    "h": [.strong, .weak, .shortPause, .weak],
    "i": [.weak, .shortPause, .strong],
    "j": [.weak, .shortPause, .strong, .weak],
    "k": [.strong, .longPause, .strong],
    "l": [.strong, .weak, .longPause, .strong],
    "m": [.strong, .longPause, .strong, .weak],
    "n": [.strong, .longPause, .strong, .weak, .weak],
    "o": [.strong, .longPause, .weak],
    "p": [.strong, .weak, .longPause, .strong],
    "q": [.strong, .weak, .longPause, .strong, .weak],
    "r": [.strong, .weak, .longPause, .weak],
    "s": [.weak, .longPause, .strong],
    "t": [.weak, .longPause, .strong, .weak],
    "u": [.strong, .longPause, .strong, .longPause, .strong],
    "v": [.strong, .weak, .longPause, .strong, .longPause],
    "w": [.weak, .shortPause, .strong, .weak, .weak],
    "x": [.strong, .longPause, .strong, .weak, .longPause],
    "y": [.strong, .longPause, .strong, .weak, .weak],
    "z": [.strong, .longPause, .weak, .weak],

    // Space
    " ": [.longPause],

    // Punctuation
    ".": [.weak, .weak],
    ",": [.weak],
    "?": [.weak, .shortPause, .weak],
    "!": [.strong, .strong],
    ":": [.weak, .longPause],
    ";": [.weak, .weak, .longPause]
]

let numberWords: [Character: String] = [
    "0": "zero",
    "1": "one",
    "2": "two",
    "3": "three",
    "4": "four",
    "5": "five",
    "6": "six",
    "7": "seven",
    "8": "eight",
    "9": "nine"
]
