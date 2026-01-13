import SwiftUI

@main
struct MyApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showOnboarding = false
    @State private var selectedTab: Tab = .help
    @State private var goToLearn = false

    @StateObject private var emergencyContacts = EmergencyContactsStore()
    @StateObject private var messageCoordinator = HelpMessageCoordinator()
    @StateObject private var settings = HaptilleSettingsStore()

    var body: some Scene {
        WindowGroup {
            ContentView(selectedTab: $selectedTab)
                .environmentObject(emergencyContacts)
                .environmentObject(messageCoordinator)
                .environmentObject(settings)
                .onAppear {
                    if !hasSeenOnboarding {
                        showOnboarding = true
                    }
                }
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingView {
                        hasSeenOnboarding = true
                        showOnboarding = false
                        goToLearn = true
                    }
                    .environmentObject(emergencyContacts)
                }
                .onChange(of: showOnboarding) { showing in
                    if !showing && goToLearn {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            selectedTab = .learn
                            goToLearn = false
                        }
                    }
                }
        }
    }
}
