//
//  haptilleLogic.swift
//  Haptille
//
//  Created by Madhan on 24/12/25.
//

import Foundation

actor HaptilleLogic {

    static let shared = HaptilleLogic()
    private let engine = HaptilleEngine()

    func play(text: String) async {
        let settings = HaptilleSettingsStore.currentSnapshot()
        let alphabet = HaptilleSettingsStore.alphabet(from: settings)
        let symbols = haptilleSymbols(from: text, alphabet: alphabet)
        for symbol in symbols {
            // Check for cancellation before each symbol
            if Task.isCancelled { break }
            await engine.execute(symbol, settings: settings)
        }
    }

    func play(symbols: [HaptilleSymbol]) async {
        let settings = HaptilleSettingsStore.currentSnapshot()
        for symbol in symbols {
            // Check for cancellation before each symbol
            if Task.isCancelled { break }
            await engine.execute(symbol, settings: settings)
        }
    }

    func stop() async {
        await engine.stop()
    }
}
