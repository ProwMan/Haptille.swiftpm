import SwiftUI

@main
struct MyApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showOnboarding = false
    @State private var selectedTab: Tab = .help
    @StateObject private var emergencyContacts = EmergencyContactsStore()
    @StateObject private var helpMessageCoordinator = HelpMessageCoordinator()
    @StateObject private var haptilleSettings = HaptilleSettingsStore()
    @State private var shouldSelectLearn = false

    var body: some Scene {
        WindowGroup {
            ContentView(selectedTab: $selectedTab)
                .environmentObject(emergencyContacts)
                .environmentObject(helpMessageCoordinator)
                .environmentObject(haptilleSettings)
                .onAppear {
                    if !hasSeenOnboarding {
                        showOnboarding = true
                    }
                }
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingView {
                        hasSeenOnboarding = true
                        showOnboarding = false
                        shouldSelectLearn = true
                    }
                    .environmentObject(emergencyContacts)
                }
                .onChange(of: showOnboarding) { isPresented in
                    if !isPresented, shouldSelectLearn {
                        // Delay tab change to avoid race condition with fullScreenCover dismissal
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            selectedTab = .learn
                            shouldSelectLearn = false
                        }
                    }
                }
        }
    }
}
