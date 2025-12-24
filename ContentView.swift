import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .help
    
    var body: some View {
        NavigationSplitView {
            List {
                SidebarRow(tab: .help, selectedTab: $selectedTab, label: {
                    Label {
                        Text(" Help ")
                    } icon: {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.tint)
                    }
                })
                SidebarRow(tab: .learn, selectedTab: $selectedTab, label: {
                    Label {
                        Text(" Learn ")
                    } icon: {
                        Image(systemName: "pencil.circle.fill")
                            .foregroundStyle(.tint)
                    }
                })
                SidebarRow(tab: .read, selectedTab: $selectedTab, label: {
                    Label {
                        Text(" Read ")
                    } icon: {
                        Image(systemName: "document.fill")
                            .foregroundStyle(.tint)
                    }
                })
                SidebarRow(tab: .converse, selectedTab: $selectedTab, label: {
                    Label {
                        Text(" Converse ")
                    } icon: {
                        Image(systemName: "bubble.left.and.text.bubble.right.fill")
                            .foregroundStyle(.tint)
                    }
                })
                SidebarRow(tab: .settings, selectedTab: $selectedTab, label: {
                    Label {
                        Text(" Settings ")
                    } icon: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.tint)
                    }
                })
            }
            .listStyle(.sidebar)
            .navigationTitle("Sidebar")
        } detail: {
            Group {
                switch selectedTab {
                case .help: helpView()
                case .learn: learnView()
                case .read: readView()
                case .converse: converseView()
                case .settings: settingsView()
                }
            }
        }
    }
}

enum Tab: Hashable {
    case help, learn, read, converse, settings
}
