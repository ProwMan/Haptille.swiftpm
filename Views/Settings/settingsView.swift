//
//  settingsView.swift
//  Haptille
//
//  Created by Madhan on 23/12/25.
//

import SwiftUI

struct settingsView: View {
    @Binding var selectedTab: Tab
    @EnvironmentObject private var emergencyContacts: EmergencyContactsStore
    @EnvironmentObject var haptilleSettings: HaptilleSettingsStore
    @State private var showOnboarding = false
    @State private var showContactPicker = false
    @State private var showPhonePicker = false
    @State private var pendingContactName = ""
    @State private var pendingPhoneNumbers: [String] = []
    @State private var shouldSelectLearn = false
    @State private var showResetConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.settings)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SettingsSection(title: "Onboarding") {
                        Button("View Onboarding") {
                            showOnboarding = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.settings)
                    }

                    SettingsSection(title: "Emergency Contacts") {
                        HStack {
                            Button {
                                showContactPicker = true
                            } label: {
                                Label("Add Contact", systemImage: "plus")
                            }
                            .buttonStyle(.bordered)

                            Spacer()
                        }

                        if emergencyContacts.contacts.isEmpty {
                            Text("No emergency contacts yet.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(emergencyContacts.contacts) { contact in
                                    HStack(alignment: .firstTextBaseline) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(contact.name)
                                                .font(.headline)
                                            Text(contact.phone)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Button(role: .destructive) {
                                            emergencyContacts.removeContact(contact)
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                    }
                                    .padding(10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(Color(.secondarySystemBackground))
                                    )
                                }
                            }
                        }
                    }

                    SettingsSection(title: "Sound Frequency") {
                        SettingSliderRow(
                            title: "Frequency",
                            value: $haptilleSettings.frequency,
                            range: 80...400,
                            step: 5,
                            valueFormat: "%.0f Hz"
                        )
                    }

                    SettingsSection(title: "Pause Durations") {
                        SettingSliderRow(
                            title: "Short pause",
                            value: $haptilleSettings.shortGap,
                            range: 0.2...3.0,
                            step: 0.1,
                            valueFormat: "%.1f s"
                        )

                        SettingSliderRow(
                            title: "Medium pause",
                            value: $haptilleSettings.mediumGap,
                            range: 0.2...3.5,
                            step: 0.1,
                            valueFormat: "%.1f s"
                        )

                        SettingSliderRow(
                            title: "Long pause",
                            value: $haptilleSettings.longGap,
                            range: 0.2...4.0,
                            step: 0.1,
                            valueFormat: "%.1f s"
                        )

                        Text("Short pause is for blank in braille, medium pause is between characters, and long pause is space.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    SettingsSection(title: "Alphabet Patterns") {
                        patternList(for: letters)
                    }

                    SettingsSection(title: "Punctuation Patterns") {
                        patternList(for: punctuation)
                    }

                    SettingsSection(title: "Factory Reset") {
                        Button(role: .destructive) {
                            showResetConfirmation = true
                        } label: {
                            Label("Reset to defaults", systemImage: "arrow.counterclockwise")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .sheet(isPresented: $showContactPicker) {
            ContactPicker(
                onSelect: { name, phones in
                    pendingContactName = name
                    pendingPhoneNumbers = phones
                    showContactPicker = false

                    if phones.count == 1, let phone = phones.first {
                        emergencyContacts.addContact(name: name, phone: phone)
                    } else if phones.count > 1 {
                        showPhonePicker = true
                    }
                },
                onCancel: { showContactPicker = false }
            )
        }
        .confirmationDialog(
            "Choose a number",
            isPresented: $showPhonePicker,
            titleVisibility: .visible
        ) {
            ForEach(pendingPhoneNumbers, id: \.self) { phone in
                Button(phone) {
                    emergencyContacts.addContact(name: pendingContactName, phone: phone)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(pendingContactName)
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView {
                showOnboarding = false
                shouldSelectLearn = true
            }
            .environmentObject(emergencyContacts)
        }
        .onChange(of: showOnboarding) { isPresented in
            if !isPresented, shouldSelectLearn {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    selectedTab = .learn
                    shouldSelectLearn = false
                }
            }
        }
        .alert("Reset to factory defaults?", isPresented: $showResetConfirmation) {
            Button("Reset", role: .destructive) {
                haptilleSettings.resetToDefaults()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will reset frequency, pauses, and patterns.")
        }
    }
}

#Preview {
    settingsView(selectedTab: .constant(.settings))
        .environmentObject(EmergencyContactsStore())
        .environmentObject(HaptilleSettingsStore())
}
