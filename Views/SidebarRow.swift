//
//  SidebarRow.swift
//  Haptille
//
//  Created by Madhan on 24/12/25.
//

import SwiftUI

struct SidebarRow<LabelView: View>: View {
    let tab: Tab
    @Binding var selectedTab: Tab
    let label: () -> LabelView
    
    var body: some View {
        Button(action: {
            selectedTab = tab
        }) {
            label()
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .padding()
        }
        .background(
            Group {
                if tab == selectedTab {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.tint.opacity(0.25))
                }
            }
        )
        .padding(.horizontal, 5)
    }
}
