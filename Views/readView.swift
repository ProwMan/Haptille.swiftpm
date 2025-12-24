//
//  readView.swift
//  Haptille
//
//  Created by Madhan on 23/12/25.
//

import SwiftUI

struct readView: View {
    @State private var inputText = ""
    private let logic = HaptilleLogic()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Read")
                .font(.title2)

            TextField("Type something to feel", text: $inputText)
                .textFieldStyle(.roundedBorder)

            Button("Play") {
                let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty else { return }
                Task { @MainActor in
                    await logic.play(text: text)
                }
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    readView()
}
