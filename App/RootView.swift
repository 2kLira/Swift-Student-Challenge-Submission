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

    private enum Step {
        case onboarding
        case simulation
        case selection
        case main
    }

    @State private var step: Step = .onboarding

    var body: some View {

        ZStack {

            switch step {

            case .onboarding:
                OnboardingView {
                    goToSimulation()
                }

            case .simulation:
                EconomicSimulationView {
                    goToSelection()
                }

            case .selection:
                SelectionView(
                    store: store,
                    onBack: { goBackFromSelection() },
                    onReady: { goToMainIfReady() }
                )

            case .main:
                MainTabsView(store: store) {
                    exitToSelection()
                }
            }
        }
        .environmentObject(accessibility)
    }
}

// MARK: - Flow

extension RootView {

    private func goToSimulation() {
        updateWithOptionalAnimation {
            step = .simulation
        }
    }

    private func goToSelection() {
        updateWithOptionalAnimation {
            step = .selection
        }
    }

    private func goToMainIfReady() {
        guard store.selectedCommunity != nil,
              store.selectedUser != nil else { return }

        updateWithOptionalAnimation {
            step = .main
        }
    }

    private func goBackFromSelection() {
        updateWithOptionalAnimation {
            step = .simulation
        }
    }

    private func exitToSelection() {
        updateWithOptionalAnimation {
            store.reset()
            step = .selection
        }
    }

    private func updateWithOptionalAnimation(_ changes: @escaping () -> Void) {
        if accessibility.animationsEnabled {
            withAnimation(.easeInOut(duration: 0.5)) {
                changes()
            }
        } else {
            changes()
        }
    }
}

#Preview {
    RootView()
}
