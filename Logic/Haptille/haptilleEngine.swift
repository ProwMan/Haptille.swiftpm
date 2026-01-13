//
//  haptilleEngine.swift
//  Haptille
//
//  Created by Madhan on 24/12/25.
//

import UIKit
import AVFoundation

@MainActor
private final class HapticHelper {
    static let shared = HapticHelper()
    private let generator = UIImpactFeedbackGenerator(style: .heavy)

    func trigger(intensity: CGFloat) {
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }
}

actor HaptilleEngine {

    private let audioEngine: AVAudioEngine?
    private let player: AVAudioPlayerNode?
    private let outputFormat: AVAudioFormat?
    private let isEngineReady: Bool

    init() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, options: [.mixWithOthers])
        try? session.setActive(true)

        let engine = AVAudioEngine()
        let mixerFormat = engine.mainMixerNode.outputFormat(forBus: 0)

        // Guard against invalid audio format (e.g., 0 channels on simulator)
        guard mixerFormat.channelCount > 0, mixerFormat.sampleRate > 0 else {
            self.audioEngine = nil
            self.player = nil
            self.outputFormat = nil
            self.isEngineReady = false
            return
        }

        guard let format = AVAudioFormat(
            standardFormatWithSampleRate: mixerFormat.sampleRate,
            channels: mixerFormat.channelCount
        ) else {
            self.audioEngine = nil
            self.player = nil
            self.outputFormat = nil
            self.isEngineReady = false
            return
        }

        let playerNode = AVAudioPlayerNode()
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
        playerNode.volume = 1.0

        do {
            try engine.start()
            self.audioEngine = engine
            self.player = playerNode
            self.outputFormat = format
            self.isEngineReady = true
        } catch {
            self.audioEngine = nil
            self.player = nil
            self.outputFormat = nil
            self.isEngineReady = false
        }
    }

    func stop() {
        player?.stop()
    }

    func execute(_ symbol: HaptilleSymbol, settings: HaptilleSettingsSnapshot) async {
        switch symbol {
        case .strong:
            await output(
                intensity: 1.0,
                gain: 2.5,
                dotDuration: settings.dotDuration,
                frequency: Float(settings.frequency)
            )
        case .weak:
            await output(
                intensity: 0.25,
                gain: 1.0,
                dotDuration: settings.dotDuration,
                frequency: Float(settings.frequency)
            )
        case .shortPause:
            await sleep(seconds: settings.shortGap)
        case .mediumPause:
            await sleep(seconds: settings.mediumGap)
        case .longPause:
            await sleep(seconds: settings.longGap)
        }
    }

    private func output(intensity: Float, gain: Float, dotDuration: Double, frequency: Float) async {
        let isPhone = await MainActor.run { UIDevice.current.userInterfaceIdiom == .phone }
        if isPhone {
            await MainActor.run {
                HapticHelper.shared.trigger(intensity: CGFloat(intensity))
            }
        } else {
            playSpeakerVibration(intensity: intensity, gain: gain, frequency: frequency, dotDuration: dotDuration)
        }

        await sleep(seconds: dotDuration)
    }

    private func playSpeakerVibration(intensity: Float, gain: Float, frequency: Float, dotDuration: Double) {
        guard isEngineReady, let outputFormat = outputFormat, let player = player else { return }

        let sampleRate = 44100
        let frameCount = Int(Float(sampleRate) * Float(dotDuration))

        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: outputFormat,
            frameCapacity: AVAudioFrameCount(frameCount)
        ) else { return }

        buffer.frameLength = buffer.frameCapacity

        if let channelData = buffer.floatChannelData {
            for i in 0..<frameCount {
                let wave = sin(2 * .pi * frequency * Float(i) / Float(sampleRate))
                let scaled = wave * intensity * gain
                let sample = max(-1.0, min(1.0, scaled))
                for channel in 0..<Int(outputFormat.channelCount) {
                    channelData[channel][i] = sample
                }
            }
        }

        player.scheduleBuffer(buffer)
        player.play()
    }

    private func sleep(seconds: Double) async {
        let nanoseconds = UInt64(seconds * 1_000_000_000)
        try? await Task.sleep(nanoseconds: nanoseconds)
    }
}
