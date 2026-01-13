import SwiftUI

@MainActor
final class ConverseViewModel: ObservableObject {
    enum Pane {
        case top
        case bottom
    }

    let topRecognizer = SpeechRecognizer()
    let bottomRecognizer = SpeechRecognizer()
    @Published var topDeafBlindMode = false
    @Published var bottomDeafBlindMode = false
    private let haptille = HaptilleLogic.shared
    private var haptilleTask: Task<Void, Never>?

    func requestAuthorization() {
        topRecognizer.requestAuthorization()
        bottomRecognizer.requestAuthorization()
    }

    func toggleRecording(for pane: Pane) {
        let current = pane == .top ? topRecognizer : bottomRecognizer
        let other = pane == .top ? bottomRecognizer : topRecognizer
        let recipientIsDeafBlind = pane == .top ? bottomDeafBlindMode : topDeafBlindMode

        if current.isRecording {
            current.stopRecording()
            if recipientIsDeafBlind {
                sendHaptille(text: current.transcript)
            }
            return
        }

        if other.isRecording {
            return
        }

        do {
            try current.startRecording()
        } catch {
            current.stopRecording()
        }
    }

    private func sendHaptille(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        haptilleTask = Task {
            await haptille.play(text: trimmed)
        }
    }

    func stopAll() {
        topRecognizer.stopRecording()
        bottomRecognizer.stopRecording()
        haptilleTask?.cancel()
        haptilleTask = nil
        Task {
            await haptille.stop()
        }
    }
}
