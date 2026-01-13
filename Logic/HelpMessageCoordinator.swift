import Foundation

@MainActor
final class HelpMessageCoordinator: ObservableObject {
    struct Draft: Identifiable {
        let id = UUID()
        let recipients: [String]
        let body: String
    }

    @Published var draft: Draft?

    func present(recipients: [String], body: String) {
        guard !recipients.isEmpty else { return }
        draft = Draft(recipients: recipients, body: body)
    }

    func dismiss() {
        draft = nil
    }
}
