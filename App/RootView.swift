//
//  RootView.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 23/02/26.
//

import SwiftUI

struct RootView: View {

    @StateObject private var store = TruequeStore()

    @State private var hasSeenOnboarding = false
    @State private var showSimulation = true

    var body: some View {

        NavigationStack {

            if !hasSeenOnboarding {

                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        hasSeenOnboarding = true
                    }
                }

            } else if showSimulation {

                EconomicSimulationView {
                    withAnimation {
                        showSimulation = false
                    }
                }

            } else if store.selectedCommunity == nil || store.selectedUser == nil {

                SelectionView(store: store)

            } else {

                MainTabsView(store: store) {
                    store.reset()
                    hasSeenOnboarding = false
                    showSimulation = true
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: hasSeenOnboarding)
    }
}
