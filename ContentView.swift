import SwiftUI

struct ContentView: View {
    @Binding var selectedTab: Tab
    @EnvironmentObject private var messageCoordinator: HelpMessageCoordinator

    var body: some View {
        NavigationSplitView {
            List {
                SidebarRow(tab: .help, selectedTab: $selectedTab) {
                    Label(" Help ", systemImage: "info")
                        .foregroundStyle(AppColors.help)
                }

                SidebarRow(tab: .read, selectedTab: $selectedTab) {
                    Label(" Read ", systemImage: "document.fill")
                        .foregroundStyle(AppColors.read)
                }

                SidebarRow(tab: .converse, selectedTab: $selectedTab) {
                    Label(" Converse ", systemImage: "bubble.left.and.text.bubble.right.fill")
                        .foregroundStyle(AppColors.converse)
                }

                SidebarRow(tab: .learn, selectedTab: $selectedTab) {
                    Label(" Learn ", systemImage: "pencil")
                        .foregroundStyle(AppColors.learn)
                }

                SidebarRow(tab: .settings, selectedTab: $selectedTab) {
                    Label(" Settings ", systemImage: "gearshape.fill")
                        .foregroundStyle(AppColors.settings)
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Haptille")
        } detail: {
            switch selectedTab {
            case .help: HelpView()
            case .read: ReadView()
            case .converse: ConverseView()
            case .learn: LearnView()
            case .settings: SettingsView(selectedTab: $selectedTab)
            }
        }
        .sheet(item: $messageCoordinator.draft) { draft in
            MessageComposer(
                recipients: draft.recipients,
                body: draft.body,
                onFinish: { messageCoordinator.dismiss() }
            )
        }
    }
}

enum Tab: Hashable {
    case help, learn, read, converse, settings
}

#Preview {
    ContentView(selectedTab: .constant(.help))
        .environmentObject(EmergencyContactsStore())
        .environmentObject(HelpMessageCoordinator())
        .environmentObject(HaptilleSettingsStore())
}
