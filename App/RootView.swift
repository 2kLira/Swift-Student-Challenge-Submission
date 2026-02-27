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

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

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
        .onAppear {
            bootstrapInitialStep()
        }
    }
}

// MARK: - Flow

extension RootView {

    private func bootstrapInitialStep() {
        // Evita “flash” raro: solo define el arranque según AppStorage.
        if hasSeenOnboarding {
            step = .simulation
        } else {
            step = .onboarding
        }
    }

    private func goToSimulation() {
        updateWithOptionalAnimation {
            hasSeenOnboarding = true
            step = .simulation
        }
    }

    private func goToSelection() {
        updateWithOptionalAnimation {
            step = .selection
        }
    }

    private func goToMainIfReady() {
        guard store.selectedCommunity != nil, store.selectedUser != nil else { return }
        updateWithOptionalAnimation {
            step = .main
        }
    }

    private func goBackFromSelection() {
        updateWithOptionalAnimation {
            // Back 1 pantalla: Selection -> Simulation
            step = .simulation
        }
    }

    private func exitToSelection() {
        updateWithOptionalAnimation {
            // Back 1 pantalla: Main -> Selection
            // (si quieres conservar ledger/estado, NO llames reset aquí)
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
