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
    private let generator = UIImpactFeedbackGenerator(style: .rigid)

    func trigger(intensity: CGFloat) {
        generator.prepare()
        generator.impactOccurred(intensity: intensity)
    }
}

actor HaptilleEngine {

    private let audioEngine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let outputFormat: AVAudioFormat

    init() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, options: [.mixWithOthers])
        try? session.setActive(true)
        let mixerFormat = audioEngine.mainMixerNode.outputFormat(forBus: 0)
        outputFormat = AVAudioFormat(
            standardFormatWithSampleRate: mixerFormat.sampleRate,
            channels: mixerFormat.channelCount
        )!
        audioEngine.attach(player)
        audioEngine.connect(player, to: audioEngine.mainMixerNode, format: outputFormat)
        try? audioEngine.start()
    }

    func execute(_ symbol: HaptilleSymbol) async {
        switch symbol {
        case .strong:
            await output(intensity: 1.0)
        case .weak:
            await output(intensity: 0.5)
        case .shortPause:
            await sleep(seconds: HaptilleTiming.shortGap)
        case .longPause:
            await sleep(seconds: HaptilleTiming.longGap)
        }
    }

    private func output(intensity: Float) async {
        let isPhone = await MainActor.run { UIDevice.current.userInterfaceIdiom == .phone }
        if isPhone {
            await MainActor.run {
                HapticHelper.shared.trigger(intensity: CGFloat(intensity))
            }
        } else {
            playSpeakerVibration(intensity: intensity)
        }

        await sleep(seconds: HaptilleTiming.dotDuration)
    }

    private func playSpeakerVibration(intensity: Float) {
        let sampleRate = 44100
        let frequency: Float = 180
        let frameCount = Int(Float(sampleRate) * Float(HaptilleTiming.dotDuration))

        let buffer = AVAudioPCMBuffer(
            pcmFormat: outputFormat,
            frameCapacity: AVAudioFrameCount(frameCount)
        )!

        buffer.frameLength = buffer.frameCapacity

        if let channelData = buffer.floatChannelData {
            for i in 0..<frameCount {
                let wave = sin(2 * .pi * frequency * Float(i) / Float(sampleRate))
                let sample = wave * intensity
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
