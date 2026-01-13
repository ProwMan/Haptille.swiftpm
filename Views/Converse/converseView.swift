import SwiftUI

struct ConverseView: View {
    @StateObject private var model = ConverseViewModel()
    var body: some View {
        GeometryReader { proxy in
            let safeInsets = proxy.safeAreaInsets
            let baseEdgePadding: CGFloat = 24
            let maxInset = max(safeInsets.top, safeInsets.bottom)
            let topLabelPadding = baseEdgePadding + (maxInset - safeInsets.top)
            let bottomLabelPadding = baseEdgePadding + (maxInset - safeInsets.bottom)
            let halfHeight = (proxy.size.height - 1) / 2
            VStack(spacing: 0) {
                ConversePane(
                    title: "User 2",
                    recognizer: model.topRecognizer,
                    otherRecognizer: model.bottomRecognizer,
                    isDeafBlindMode: $model.topDeafBlindMode,
                    labelEdgePadding: topLabelPadding,
                    onToggleRecording: { model.toggleRecording(for: .top) }
                )
                .frame(height: halfHeight)
                .rotationEffect(.degrees(180))

                Divider()

                ConversePane(
                    title: "User 1",
                    recognizer: model.bottomRecognizer,
                    otherRecognizer: model.topRecognizer,
                    isDeafBlindMode: $model.bottomDeafBlindMode,
                    labelEdgePadding: bottomLabelPadding,
                    onToggleRecording: { model.toggleRecording(for: .bottom) }
                )
                .frame(height: halfHeight)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .onAppear {
            PermissionGate.runOnce(key: "hasRequestedConversePermissions") {
                model.requestAuthorization()
            }
        }
        .onDisappear {
            model.stopAll()
        }
    }
}

#Preview {
    ConverseView()
}
