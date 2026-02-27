//
//  MainTabsView.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 23/02/26.
//

import SwiftUI

struct MainTabsView: View {

    @ObservedObject var store: TruequeStore

    /// Closure que controla la salida al nivel anterior (Selection)
    var onExit: () -> Void

    @State private var selection: TabSelection = .dashboard

    var body: some View {

        TabView(selection: $selection) {

            DashboardView(
                store: store,
                onExit: onExit
            )
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
        .tabViewStyle(.automatic)
    }
}

extension MainTabsView {

    enum TabSelection: Hashable {
        case dashboard
        case network
    }
}
