import SwiftUI

@main
struct MyApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showOnboarding = false
    @State private var selectedTab: Tab = .help

    var body: some Scene {
        WindowGroup {
            ContentView(selectedTab: $selectedTab)
                .onAppear {
                    if !hasSeenOnboarding {
                        showOnboarding = true
                    }
                }
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingView {
                        hasSeenOnboarding = true
                        showOnboarding = false
                        selectedTab = .learn
                    }
                }
        }
    }
}
