//
//  EconomicSimulationView.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import SwiftUI
import UIKit

struct EconomicSimulationView: View {

    var onEnter: () -> Void

    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var exchanges: Int = 0
    @State private var circulated: Int = 0
    @State private var trust: Double = 0.62
    @State private var communityValue: Int = 0

    @State private var dragOffset: CGFloat = 0
    @State private var activated = false
    @State private var showClosing = false
    @State private var pulse = false
    @State private var velocityActive = false

    var body: some View {
        mainView
    }
}

//////////////////////////////////////////////////////////////
// MARK: - Main View
//////////////////////////////////////////////////////////////

extension EconomicSimulationView {

    private var mainView: some View {

        ZStack {

            LinearGradient(
                colors: activated
                    ? [Color.backgroundSand.opacity(0.9), Color.white]
                    : [Color.backgroundSand, Color.white.opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: activated)

            VStack(spacing: sizeClass == .regular ? 34 : 30) {

                Spacer()

                VStack(spacing: 8) {

                    Text("TRUEQUE TIDE")
                        .font(.system(size: sizeClass == .regular ? 26 : 22, weight: .medium))
                        .tracking(sizeClass == .regular ? 7 : 6)
                        .foregroundColor(.oceanBase)

                    Text("Value circulates where systems fall short.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .opacity(activated ? 0 : 1)
                        .animation(.easeInOut(duration: 0.6), value: activated)
                }

                metricsSection

                if activated {

                    impactSection
                        .transition(.opacity.combined(with: .move(edge: .bottom)))

                    tradeCards
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                if showClosing {

                    closingSection
                        .transition(.opacity)
                }

                Spacer()

                if !activated {
                    Text("Swipe up to activate")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.bottom, sizeClass == .regular ? 54 : 40)
                        .opacity(dragOffset < -30 ? 0 : 1)
                }
            }
            .padding(sizeClass == .regular ? 34 : 20)
            .frame(maxWidth: sizeClass == .regular ? 900 : .infinity)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.height
                }
                .onEnded { _ in
                    if dragOffset < -120 {
                        activateEconomy()
                    }
                    dragOffset = 0
                }
        )
    }

    private var closingSection: some View {

        VStack(spacing: 18) {

            Text("Where access is limited, trust becomes currency — sustained by people.")
                .font(.system(size: sizeClass == .regular ? 20 : 18, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.oceanBase)
                .padding(.horizontal)

            Button {
                selectionFeedback()
                onEnter()
            } label: {
                HStack(spacing: 6) {
                    Text("Enter Community")
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.oceanAccent)
                .padding(.vertical, 10)
                .padding(.horizontal, 22)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.oceanAccent.opacity(0.5), lineWidth: 1)
                )
            }
        }
    }
}

//////////////////////////////////////////////////////////////
// MARK: - Metrics
//////////////////////////////////////////////////////////////

extension EconomicSimulationView {

    private var metricsSection: some View {

        VStack(spacing: 12) {

            HStack(spacing: sizeClass == .regular ? 44 : 30) {

                metricBlock(value: exchanges, label: "Exchanges")
                metricBlock(value: circulated, label: "Circulated", suffix: " TT")
                trustBlock
            }
            .padding(sizeClass == .regular ? 20 : 16)
            .background(Color.white.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(
                color: pulse ? Color.oceanAccent.opacity(0.2) : .black.opacity(0.05),
                radius: pulse ? 20 : 10
            )
            .scaleEffect(pulse ? 1.04 : 1.0)
            .animation(.easeOut(duration: 0.4), value: pulse)

            if velocityActive {

                HStack(spacing: 8) {

                    Circle()
                        .fill(Color.oceanAccent)
                        .frame(width: 8, height: 8)
                        .scaleEffect(pulse ? 1.4 : 1.0)
                        .animation(.easeInOut(duration: 0.4), value: pulse)

                    Text("Economic Flow Active")
                        .font(.caption)
                        .foregroundColor(.oceanBase.opacity(0.7))
                }
                .transition(.opacity)
            }
        }
    }

    private var impactSection: some View {

        VStack(spacing: 6) {

            Text("Community Value Generated")
                .font(.caption)
                .foregroundColor(.oceanBase.opacity(0.6))

            Text("\(communityValue) TT")
                .font(.system(size: sizeClass == .regular ? 30 : 26, weight: .medium))
                .foregroundColor(.oceanAccent)
        }
        .padding(sizeClass == .regular ? 18 : 14)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 8)
    }

    private func metricBlock(value: Int, label: String, suffix: String = "") -> some View {

        VStack(spacing: 6) {
            Text("\(value)\(suffix)")
                .font(.system(size: sizeClass == .regular ? 20 : 17, weight: .semibold))
                .foregroundColor(.oceanBase)

            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    private var trustBlock: some View {

        VStack(alignment: .leading, spacing: 6) {

            Text("\(Int(trust * 100))%")
                .font(.system(size: sizeClass == .regular ? 20 : 17, weight: .semibold))
                .foregroundColor(.oceanBase)

            ZStack(alignment: .leading) {

                Capsule()
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: sizeClass == .regular ? 92 : 70, height: 6)

                Capsule()
                    .fill(Color.oceanAccent)
                    .frame(width: (sizeClass == .regular ? 92 : 70) * trust, height: 6)
                    .animation(.easeInOut(duration: 0.2), value: trust)
            }

            Text("Trust")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

//////////////////////////////////////////////////////////////
// MARK: - Trade Cards
//////////////////////////////////////////////////////////////

extension EconomicSimulationView {

    private var tradeCards: some View {

        Group {
            if sizeClass == .regular {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    tradeCard(
                        title: "Childcare Support",
                        description: "Helping a neighbor with childcare.",
                        value: 3
                    )

                    tradeCard(
                        title: "Water Delivery",
                        description: "Transporting clean water.",
                        value: 5
                    )
                }
                .padding(.top, 4)
            } else {
                VStack(spacing: 15) {
                    tradeCard(
                        title: "Childcare Support",
                        description: "Helping a neighbor with childcare.",
                        value: 3
                    )

                    tradeCard(
                        title: "Water Delivery",
                        description: "Transporting clean water.",
                        value: 5
                    )
                }
            }
        }
    }

    private func tradeCard(title: String, description: String, value: Int) -> some View {

        HStack {

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text("\(value) TT")
                .font(.caption)
                .foregroundColor(.oceanAccent)
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
}

//////////////////////////////////////////////////////////////
// MARK: - Activation Logic
//////////////////////////////////////////////////////////////

extension EconomicSimulationView {

    private func activateEconomy() {

        guard !activated else { return }

        activated = true
        velocityActive = true

        mediumImpact()
        triggerPulse()

        animateCounter(
            targetExchanges: 12,
            targetCirculated: 48,
            targetTrust: 0.87,
            duration: 1.4
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            lightImpact()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeInOut(duration: 0.8)) {
                showClosing = true
            }
        }
    }

    private func animateCounter(
        targetExchanges: Int,
        targetCirculated: Int,
        targetTrust: Double,
        duration: Double
    ) {

        let steps = 40
        let interval = duration / Double(steps)

        for step in 1...steps {

            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(step)) {

                let progress = Double(step) / Double(steps)

                exchanges = Int(Double(targetExchanges) * progress)
                circulated = Int(Double(targetCirculated) * progress)
                trust = 0.62 + (targetTrust - 0.62) * progress
                communityValue = circulated
            }
        }
    }

    private func triggerPulse() {
        pulse = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            pulse = false
        }
    }
}

//////////////////////////////////////////////////////////////
// MARK: - Haptics
//////////////////////////////////////////////////////////////

extension EconomicSimulationView {

    private func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    private func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    private func selectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
