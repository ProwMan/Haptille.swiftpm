import Foundation

struct EmergencyContact: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let phone: String
}

@MainActor
final class EmergencyContactsStore: ObservableObject {
    @Published private(set) var contacts: [EmergencyContact] = [] {
        didSet { persist() }
    }

    private let storageKey = "emergencyContactsData"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.contacts = loadContacts()
    }

    func addContact(name: String, phone: String) {
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPhone.isEmpty else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName = trimmedName.isEmpty ? trimmedPhone : trimmedName
        let contact = EmergencyContact(id: UUID(), name: displayName, phone: trimmedPhone)

        if let index = contacts.firstIndex(where: { $0.phone == trimmedPhone }) {
            contacts[index] = contact
        } else {
            contacts.append(contact)
        }
    }

    func removeContact(_ contact: EmergencyContact) {
        contacts.removeAll { $0.id == contact.id }
    }

    var recipientNumbers: [String] {
        contacts.map { $0.phone }
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(contacts) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private func loadContacts() -> [EmergencyContact] {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([EmergencyContact].self, from: data) else {
            return []
        }
        return decoded
    }
}
