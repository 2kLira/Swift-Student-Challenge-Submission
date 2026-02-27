//
//  RootView.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 23/02/26.
//

import SwiftUI

struct RootView: View {

    @StateObject private var store = TruequeStore()
    @StateObject private var accessibility = AccessibilityManager()

    @State private var hasSeenOnboarding = false
    @State private var showSimulation = true

    var body: some View {

        NavigationStack {

            if !hasSeenOnboarding {

                OnboardingView {
                    withAnimation(animationStyle) {
                        hasSeenOnboarding = true
                    }
                }

            } else if showSimulation {

                EconomicSimulationView {
                    withAnimation(animationStyle) {
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
        .animation(animationStyle, value: hasSeenOnboarding)
        .environmentObject(accessibility)
    }

    // MARK: - Animation Style (Reduce Motion Support)

    private var animationStyle: Animation? {
        accessibility.reduceMotionMode ? nil : .easeInOut(duration: 0.5)
    }
}

#Preview {
    RootView()
}
