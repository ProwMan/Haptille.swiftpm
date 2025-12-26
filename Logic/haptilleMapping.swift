//
//  haptilleMapping.swift
//  Haptille
//
//  Created by Madhan on 24/12/25.
//

import Foundation

let haptilleAlphabet: [Character: [HaptilleSymbol]] = [
    "a": [.weak, .shortPause, .shortPause],
    "b": [.weak, .weak, .shortPause],
    "c": [.strong, .shortPause, .shortPause],
    "d": [.strong, .weak, .shortPause],
    "e": [.weak, .weak, .shortPause],
    "f": [.strong, .weak, .shortPause],
    "g": [.strong, .strong, .shortPause],
    "h": [.weak, .strong, .shortPause],
    "i": [.weak, .weak, .shortPause],
    "j": [.weak, .strong, .shortPause],
    "k": [.weak, .shortPause, .weak],
    "l": [.weak, .weak, .weak],
    "m": [.strong, .shortPause, .weak],
    "n": [.strong, .weak, .weak],
    "o": [.weak, .weak, .weak],
    "p": [.strong, .weak, .weak],
    "q": [.strong, .strong, .weak],
    "r": [.weak, .strong, .weak],
    "s": [.weak, .weak, .weak],
    "t": [.weak, .strong, .weak],
    "u": [.weak, .shortPause, .strong],
    "v": [.weak, .weak, .strong],
    "w": [.weak, .strong, .weak],
    "x": [.strong, .shortPause, .strong],
    "y": [.strong, .weak, .strong],
    "z": [.weak, .weak, .strong],

    // Space
    " ": [.longPause],

    // Punctuation
    ".": [.shortPause, .strong, .weak],
    ",": [.shortPause, .weak,.shortPause],
    "?": [.shortPause, .weak, .strong],
    "!": [.shortPause, .strong, .weak]
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
