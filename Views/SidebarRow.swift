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
        Button {
            selectedTab = tab
        } label: {
            label()
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.tint.opacity(tab == selectedTab ? 0.25 : 0))
        )
        .padding(.horizontal, 5)
    }
}
