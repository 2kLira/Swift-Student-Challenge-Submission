//
//  MainTabsView.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 23/02/26.
//

import SwiftUI

struct MainTabsView: View {

    @ObservedObject var store: TruequeStore
    var reset: () -> Void

    @State private var selection: TabSelection = .dashboard

    var body: some View {

        TabView(selection: $selection) {

            DashboardView(store: store, reset: reset)
                .tabItem {
                    Image(systemName: "hand.raised.fill")
                    Text("Favores")
                }
                .tag(TabSelection.dashboard)

            CommunityNetworkView(store: store)
                .tabItem {
                    Image(systemName: "network")
                    Text("Red")
                }
                .tag(TabSelection.network)
        }
        .tabViewStyle(.automatic) // asegura comportamiento tipo iPhone también en iPad
    }
}

//////////////////////////////////////////////////////////////
// MARK: - Tab Enum
//////////////////////////////////////////////////////////////

extension MainTabsView {

    enum TabSelection: Hashable {
        case dashboard
        case network
    }
}
