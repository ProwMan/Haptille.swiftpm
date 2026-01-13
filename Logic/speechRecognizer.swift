//
//  speechRecognizer.swift
//  Haptille
//
//  Created by Madhan on 23/12/25.
//

import AVFoundation
import Speech

@MainActor
final class speechRecognizer: ObservableObject {
    @Published var transcript = ""
    @Published var isRecording = false
    @Published var isAuthorized = false

    private var recognizer: SFSpeechRecognizer?
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var speechAuthorized = false
    private var micAuthorized = false
    private var hasUsageDescriptions: Bool {
        Bundle.main.object(forInfoDictionaryKey: "NSMicrophoneUsageDescription") != nil
            && Bundle.main.object(forInfoDictionaryKey: "NSSpeechRecognitionUsageDescription") != nil
    }

    func requestAuthorization() {
        guard hasUsageDescriptions else {
            isAuthorized = false
            return
        }

        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor in
                guard let self else { return }
                self.speechAuthorized = status == .authorized
                self.updateAuthorization()
            }
        }

        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            Task { @MainActor in
                guard let self else { return }
                self.micAuthorized = granted
                self.updateAuthorization()
            }
        }
    }

    func startRecording() throws {
        guard hasUsageDescriptions else { return }
        if recognizer == nil {
            recognizer = SFSpeechRecognizer()
        }
        guard isAuthorized, let recognizer, recognizer.isAvailable else { return }

        if audioEngine == nil {
            audioEngine = AVAudioEngine()
        }
        guard let audioEngine else { return }

        if audioEngine.isRunning {
            stopRecording()
        }

        transcript = ""
        request = SFSpeechAudioBufferRecognitionRequest()
        request?.shouldReportPartialResults = true

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        // Guard against invalid audio format (e.g., 0 channels on simulator)
        guard format.channelCount > 0 else {
            isRecording = false
            return
        }

        inputNode.removeTap(onBus: 0)

        // Capture request locally to avoid accessing @MainActor self from audio thread
        let currentRequest = request
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            currentRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true

        guard let request else { return }
        task = recognizer.recognitionTask(with: request) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                if let result = result {
                    self.transcript = result.bestTranscription.formattedString
                }
                if result?.isFinal == true || error != nil {
                    self.stopRecording()
                }
            }
        }
    }

    func stopRecording() {
        task?.cancel()
        task = nil

        if let audioEngine, audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        request?.endAudio()
        request = nil
        isRecording = false
    }

    private func updateAuthorization() {
        isAuthorized = speechAuthorized && micAuthorized
    }
}
