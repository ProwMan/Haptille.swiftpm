import AVFoundation
import Speech

@MainActor
final class SpeechRecognizer: ObservableObject {
    @Published var transcript = ""
    @Published var isRecording = false
    @Published var isAuthorized = false

    private var recognizer: SFSpeechRecognizer?
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var speechOk = false
    private var micOk = false

    private var hasPermissionKeys: Bool {
        let mic = Bundle.main.object(forInfoDictionaryKey: "NSMicrophoneUsageDescription")
        let speech = Bundle.main.object(forInfoDictionaryKey: "NSSpeechRecognitionUsageDescription")
        return mic != nil && speech != nil
    }

    func requestAuthorization() {
        guard hasPermissionKeys else {
            isAuthorized = false
            return
        }

        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            Task { @MainActor in
                self?.speechOk = status == .authorized
                self?.updateAuth()
            }
        }

        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            Task { @MainActor in
                self?.micOk = granted
                self?.updateAuth()
            }
        }
    }

    func startRecording() throws {
        guard hasPermissionKeys else { return }

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

        guard format.channelCount > 0 else {
            isRecording = false
            return
        }

        inputNode.removeTap(onBus: 0)

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
                if let result {
                    self?.transcript = result.bestTranscription.formattedString
                }
                if result?.isFinal == true || error != nil {
                    self?.stopRecording()
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

    private func updateAuth() {
        isAuthorized = speechOk && micOk
    }
}
