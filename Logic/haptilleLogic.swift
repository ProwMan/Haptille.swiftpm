//
//  haptilleLogic.swift
//  Haptille
//
//  Created by Madhan on 24/12/25.
//

import Foundation

actor HaptilleLogic {

    private let engine = HaptilleEngine()

    func play(text: String) async {
        let symbols = haptilleSymbols(from: text)
        for symbol in symbols {
            await engine.execute(symbol)
        }
    }
}
