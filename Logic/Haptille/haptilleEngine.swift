import UIKit
import AVFoundation

@MainActor
private final class HapticHelper {
    static let shared = HapticHelper()
    private let generator = UIImpactFeedbackGenerator(style: .heavy)

    func trigger(_ intensity: CGFloat) {
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }
}

actor HaptilleEngine {
    private let audioEngine: AVAudioEngine?
    private let player: AVAudioPlayerNode?
    private let format: AVAudioFormat?
    private let ready: Bool

    init() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, options: [.mixWithOthers])
        try? session.setActive(true)

        let engine = AVAudioEngine()
        let mixerFormat = engine.mainMixerNode.outputFormat(forBus: 0)

        guard mixerFormat.channelCount > 0,
              mixerFormat.sampleRate > 0,
              let fmt = AVAudioFormat(
                  standardFormatWithSampleRate: mixerFormat.sampleRate,
                  channels: mixerFormat.channelCount
              ) else {
            audioEngine = nil
            player = nil
            format = nil
            ready = false
            return
        }

        let node = AVAudioPlayerNode()
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: fmt)
        node.volume = 1.0

        do {
            try engine.start()
            audioEngine = engine
            player = node
            format = fmt
            ready = true
        } catch {
            audioEngine = nil
            player = nil
            format = nil
            ready = false
        }
    }

    func stop() {
        player?.stop()
    }

    func execute(_ symbol: HaptilleSymbol, settings: HaptilleSettingsSnapshot) async {
        switch symbol {
        case .strong:
            await output(intensity: 1.0, gain: 2.5, duration: settings.dotDuration, freq: settings.frequency)
        case .weak:
            await output(intensity: 0.25, gain: 1.0, duration: settings.dotDuration, freq: settings.frequency)
        case .shortPause:
            await pause(settings.shortGap)
        case .mediumPause:
            await pause(settings.mediumGap)
        case .longPause:
            await pause(settings.longGap)
        }
    }

    private func output(intensity: Float, gain: Float, duration: Double, freq: Double) async {
        let isPhone = await MainActor.run {
            UIDevice.current.userInterfaceIdiom == .phone
        }

        if isPhone {
            await MainActor.run {
                HapticHelper.shared.trigger(CGFloat(intensity))
            }
        } else {
            playTone(intensity: intensity, gain: gain, freq: Float(freq), duration: duration)
        }

        await pause(duration)
    }

    private func playTone(intensity: Float, gain: Float, freq: Float, duration: Double) {
        guard ready, let format, let player else { return }

        let sampleRate: Float = 44100
        let frameCount = Int(sampleRate * Float(duration))

        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: AVAudioFrameCount(frameCount)
        ) else { return }

        buffer.frameLength = buffer.frameCapacity

        guard let channelData = buffer.floatChannelData else { return }

        for i in 0..<frameCount {
            let wave = sin(2 * .pi * freq * Float(i) / sampleRate)
            let sample = max(-1.0, min(1.0, wave * intensity * gain))
            for ch in 0..<Int(format.channelCount) {
                channelData[ch][i] = sample
            }
        }

        player.scheduleBuffer(buffer)
        player.play()
    }

    private func pause(_ seconds: Double) async {
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}
