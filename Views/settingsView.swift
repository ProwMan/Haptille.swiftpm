//
//  settingsView.swift
//  Haptille
//
//  Created by Madhan on 23/12/25.
//

import SwiftUI

struct settingsView: View {
    @State private var showOnboarding = false

    var body: some View {
        VStack(spacing: 16) {
            Text("Settings")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Button("View Onboarding") {
                showOnboarding = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView {
                showOnboarding = false
            }
        }
    }
}

#Preview {
    settingsView()
}
