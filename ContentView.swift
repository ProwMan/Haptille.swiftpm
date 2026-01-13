import SwiftUI

struct ContentView: View {
    @Binding var selectedTab: Tab
    @EnvironmentObject private var helpMessageCoordinator: HelpMessageCoordinator
    
    var body: some View {
        NavigationSplitView {
            List {
                SidebarRow(tab: .help, selectedTab: $selectedTab, label: {
                    Label {
                        Text(" Help ")
                    } icon: {
                        Image(systemName: "info")
                            .foregroundStyle(AppColors.help)
                    }
                })
                
                SidebarRow(tab: .read, selectedTab: $selectedTab, label: {
                    Label {
                        Text(" Read ")
                    } icon: {
                        Image(systemName: "document.fill")
                            .foregroundStyle(AppColors.read)
                    }
                })
                
                SidebarRow(tab: .converse, selectedTab: $selectedTab, label: {
                    Label {
                        Text(" Converse ")
                    } icon: {
                        Image(systemName: "bubble.left.and.text.bubble.right.fill")
                            .foregroundStyle(AppColors.converse)
                    }
                })
                
                SidebarRow(tab: .learn, selectedTab: $selectedTab, label: {
                    Label {
                        Text(" Learn ")
                    } icon: {
                        Image(systemName: "pencil")
                            .foregroundStyle(AppColors.learn)
                    }
                })
                
                SidebarRow(tab: .settings, selectedTab: $selectedTab, label: {
                    Label {
                        Text(" Settings ")
                    } icon: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(AppColors.settings)
                    }
                })
            }
            .listStyle(.sidebar)
            .navigationTitle("Haptille")
        } detail: {
            Group {
                switch selectedTab {
                case .help: helpView()
                case .learn: learnView()
                case .read: readView()
                case .converse: converseView()
                case .settings: settingsView(selectedTab: $selectedTab)
                }
            }
        }
        .sheet(item: $helpMessageCoordinator.draft) { draft in
            MessageComposer(
                recipients: draft.recipients,
                body: draft.body,
                onFinish: { helpMessageCoordinator.dismiss() }
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
