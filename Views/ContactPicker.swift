import Contacts
import ContactsUI
import SwiftUI

struct ContactPicker: UIViewControllerRepresentable {
    let onSelect: (String, [String]) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let controller = CNContactPickerViewController()
        controller.delegate = context.coordinator
        controller.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        controller.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
        controller.predicateForSelectionOfContact = NSPredicate(format: "phoneNumbers.@count > 0")
        return controller
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect, onCancel: onCancel)
    }

    final class Coordinator: NSObject, CNContactPickerDelegate {
        let onSelect: (String, [String]) -> Void
        let onCancel: () -> Void

        init(onSelect: @escaping (String, [String]) -> Void,
             onCancel: @escaping () -> Void) {
            self.onSelect = onSelect
            self.onCancel = onCancel
        }

        func contactPicker(_ picker: CNContactPickerViewController,
                           didSelect contact: CNContact) {
            let name = CNContactFormatter.string(from: contact, style: .fullName) ?? "Emergency Contact"
            let numbers = contact.phoneNumbers.map { $0.value.stringValue }
            onSelect(name, numbers)
        }

        func contactPicker(_ picker: CNContactPickerViewController,
                           didSelect contactProperty: CNContactProperty) {
            guard contactProperty.key == CNContactPhoneNumbersKey,
                  let phoneNumber = contactProperty.value as? CNPhoneNumber else {
                return
            }
            let contact = contactProperty.contact
            let name = CNContactFormatter.string(from: contact, style: .fullName) ?? "Emergency Contact"
            onSelect(name, [phoneNumber.stringValue])
        }

        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            onCancel()
        }
    }
}
