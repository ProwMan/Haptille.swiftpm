//
//  textScannerView.swift
//  Haptille
//
//  Created by Madhan on 23/12/25.
//

import SwiftUI
import VisionKit

struct textScannerView: UIViewControllerRepresentable {
    @Binding var scannedText: String
    @Binding var isPresented: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let viewController = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .balanced,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        viewController.delegate = context.coordinator
        try? viewController.startScanning()
        return viewController
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let parent: textScannerView

        init(parent: textScannerView) {
            self.parent = parent
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            if case let .text(textItem) = item {
                parent.scannedText = textItem.transcript
                parent.isPresented = false
            }
        }
    }
}
