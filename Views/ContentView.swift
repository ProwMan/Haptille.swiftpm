import SwiftUI

struct ContentView: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        NavigationSplitView {
            List {
                SidebarRow(tab: .help, selectedTab: $selectedTab, label: {
                    Label {
                        Text(" Help ")
                    } icon: {
                        Image(systemName: "info")
                            .foregroundStyle(Color(red: 0.839, green: 0.271, blue: 0.271))
                    }
                })
                
                SidebarRow(tab: .read, selectedTab: $selectedTab, label: {
                    Label {
                        Text(" Read ")
                    } icon: {
                        Image(systemName: "document.fill")
                            .foregroundStyle(Color(red: 0.145, green: 0.388, blue: 0.922))
                    }
                })
                
                SidebarRow(tab: .converse, selectedTab: $selectedTab, label: {
                    Label {
                        Text(" Converse ")
                    } icon: {
                        Image(systemName: "bubble.left.and.text.bubble.right.fill")
                            .foregroundStyle(Color(red: 0.173, green: 0.749, blue: 0.631))
                    }
                })
                
                SidebarRow(tab: .learn, selectedTab: $selectedTab, label: {
                    Label {
                        Text(" Learn ")
                    } icon: {
                        Image(systemName: "pencil")
                            .foregroundStyle(Color(red: 0.839, green: 0.620, blue: 0.180))
                    }
                })
                
                SidebarRow(tab: .settings, selectedTab: $selectedTab, label: {
                    Label {
                        Text(" Settings ")
                    } icon: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.gray)
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
                case .settings: settingsView()
                }
            }
        }
    }
}

enum Tab: Hashable {
    case help, learn, read, converse, settings
}


#Preview {
    ContentView(selectedTab: .constant(.help))
}
