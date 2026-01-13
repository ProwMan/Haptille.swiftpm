//
//  helpView.swift
//  Haptille
//
//  Created by Madhan on 23/12/25.
//

import CoreLocation
import MessageUI
import SwiftUI

struct helpView: View {
    @EnvironmentObject private var emergencyContacts: EmergencyContactsStore
    @EnvironmentObject private var helpMessageCoordinator: HelpMessageCoordinator
    @StateObject private var locationProvider = LocationProvider()
    @State private var isPreparingMessage = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    private var recipients: [String] {
        emergencyContacts.recipientNumbers
    }

    private var hasContacts: Bool {
        !recipients.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Help")
                .font(.title2)

            Button(action: sendEmergencyMessage) {
                Label(
                    isPreparingMessage ? "Preparing message..." : "Send emergency message",
                    systemImage: "location.fill"
                )
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.help)
            .disabled(isPreparingMessage)

            Button(action: sendEmergencyMessageWithoutLocation) {
                Label("Send emergency message (no location)", systemImage: "message.fill")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .buttonStyle(.bordered)
            .tint(AppColors.help)
            .disabled(isPreparingMessage)

            Spacer()
        }
        .padding()
        .alert("Unable to Send", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private func sendEmergencyMessage() {
        guard hasContacts else {
            showAlert(message: "Add emergency contacts in Settings first.")
            return
        }

        guard MFMessageComposeViewController.canSendText() else {
            showAlert(message: "This device cannot send text messages.")
            return
        }

        isPreparingMessage = true
        locationProvider.requestLocation { result in
            DispatchQueue.main.async {
                isPreparingMessage = false
                switch result {
                case .success(let location):
                    helpMessageCoordinator.present(
                        recipients: recipients,
                        body: emergencyMessageBody(location: location)
                    )
                case .failure(let error):
                    handleLocationError(error)
                }
            }
        }
    }

    private func emergencyMessageBody(location: CLLocation?) -> String {
        guard let location else {
            return "Emergency: I need help. My location is unavailable."
        }

        let lat = String(format: "%.5f", locale: Locale(identifier: "en_US_POSIX"),
                         location.coordinate.latitude)
        let lon = String(format: "%.5f", locale: Locale(identifier: "en_US_POSIX"),
                         location.coordinate.longitude)
        let mapLink = "https://maps.apple.com/?ll=\(lat),\(lon)"
        return "Emergency: I need help. My current location: \(mapLink)"
    }

    private func handleLocationError(_: Error) {
        helpMessageCoordinator.present(
            recipients: recipients,
            body: emergencyMessageBody(location: nil)
        )
    }

    private func sendEmergencyMessageWithoutLocation() {
        guard hasContacts else {
            showAlert(message: "Add emergency contacts in Settings first.")
            return
        }

        guard MFMessageComposeViewController.canSendText() else {
            showAlert(message: "This device cannot send text messages.")
            return
        }

        helpMessageCoordinator.present(
            recipients: recipients,
            body: emergencyMessageBody(location: nil)
        )
    }

    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}

#Preview {
    helpView()
        .environmentObject(EmergencyContactsStore())
        .environmentObject(HelpMessageCoordinator())
}
