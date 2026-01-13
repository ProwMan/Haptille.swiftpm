import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var emergencyContacts: EmergencyContactsStore
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Feel Braille Patterns",
            subtitle: "Use braille pattern in your devices through touch.\nYou will need help to set up the app and learn to use Haptille.",
            systemImage: "hand.tap.fill",
            accent: AppColors.settings,
            actionTitle: nil,
            blocksProgressUntilContacts: false
        ),
        OnboardingPage(
            title: "Help",
            subtitle: "Add emergency contacts to quickly send a help message with your location.",
            systemImage: "location.fill",
            accent: AppColors.help,
            actionTitle: "Add emergency contacts",
            blocksProgressUntilContacts: true
        ),
        OnboardingPage(
            title: "Read",
            subtitle: "Use Haptille to read text not in braille format without any help from others.",
            systemImage: "document.fill",
            accent: AppColors.read,
            actionTitle: nil,
            blocksProgressUntilContacts: false
        ),
        OnboardingPage(
            title: "Converse",
            subtitle: "Use Haptille to converse with others without any help from others.",
            systemImage: "text.bubble.fill",
            accent: AppColors.converse,
            actionTitle: nil,
            blocksProgressUntilContacts: false
        ),
        OnboardingPage(
            title: "Learn",
            subtitle: "Learn the haptille format for easy access to digital services.",
            systemImage: "pencil",
            accent: AppColors.learn,
            actionTitle: nil,
            blocksProgressUntilContacts: false
        )
    ]

    let onFinish: () -> Void
    @State private var selection = 0
    @State private var showContactPicker = false
    @State private var showPhonePicker = false
    @State private var pendingContactName = ""
    @State private var pendingPhoneNumbers: [String] = []

    private var contactGateIndex: Int? {
        pages.firstIndex { $0.blocksProgressUntilContacts }
    }

    private var maxAllowedIndex: Int {
        guard emergencyContacts.contacts.isEmpty,
              let gateIndex = contactGateIndex else {
            return pages.count - 1
        }
        return gateIndex
    }

    private var isLastPage: Bool {
        selection >= pages.count - 1
    }

    private var canProceed: Bool {
        isLastPage || selection < maxAllowedIndex
    }

    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                ForEach(pages.indices, id: \.self) { index in
                    let page = pages[index]
                    let isHelpPage = page.blocksProgressUntilContacts
                    let contactCount = emergencyContacts.contacts.count
                    let contactPluralSuffix = contactCount == 1 ? "" : "s"
                    let statusTitle = isHelpPage
                        ? contactCount == 0
                            ? "No emergency contacts added yet."
                            : "Added \(contactCount) emergency contact\(contactPluralSuffix)."
                        : nil
                    let statusItems = isHelpPage
                        ? emergencyContacts.contacts.map { "\($0.name) · \($0.phone)" }
                        : []
                    OnboardingCard(
                        page: page,
                        onAction: page.actionTitle == nil ? nil : { showContactPicker = true },
                        statusTitle: statusTitle,
                        statusItems: statusItems
                    )
                        .tag(index)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 40)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
        .overlay(alignment: .bottom) {
            Button(selection < pages.count - 1 ? "Next" : "Get Started") {
                if selection < pages.count - 1 {
                    selection += 1
                } else {
                    onFinish()
                }
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .tint(pages[selection].accent)
            .padding(.bottom, 100)
            .disabled(!canProceed)
        }
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
        .onChange(of: selection) { newValue in
            let allowed = maxAllowedIndex
            if newValue > allowed {
                selection = allowed
            }
        }
    }
}

#Preview {
    OnboardingView(onFinish: {})
        .environmentObject(EmergencyContactsStore())
}
