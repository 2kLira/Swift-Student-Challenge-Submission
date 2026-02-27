//
//  CommunityMetricsHeader.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 23/02/26.
//


import SwiftUI

struct CommunityMetricsHeader: View {

    @ObservedObject var store: TruequeStore

    @State private var animatedExchanges: Double = 0
    @State private var animatedCirculated: Double = 0
    @State private var animatedTrust: Double = 0

    var body: some View {

        HStack(spacing: 28) {

            metricBlock(
                value: Int(animatedExchanges),
                label: "Exchanges"
            )

            metricBlock(
                value: Int(animatedCirculated),
                label: "TT Circulated"
            )

            trustRing
        }
        .padding(.vertical, 14)
        .padding(.horizontal)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(Color.glassBorder, lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.bottom, 8)
        .onAppear { animateAll() }
        .onChange(of: store.totalExchanges) { _ in animateAll() }
        .onChange(of: store.totalCirculated) { _ in animateAll() }
        .onChange(of: store.communityTrust) { _ in animateAll() }
    }

    // MARK: - Metric Block

    private func metricBlock(value: Int, label: String) -> some View {

        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.oceanAccent)

            Text(label)
                .font(.caption2)
                .foregroundColor(.oceanBase.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Trust Ring

    private var trustRing: some View {

        ZStack {

            Circle()
                .stroke(Color.oceanBase.opacity(0.12), lineWidth: 6)

            Circle()
                .trim(from: 0, to: max(0, min(animatedTrust, 1)))
                .stroke(
                    Color.oceanAccent,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: animatedTrust)

            Text("\(Int(animatedTrust * 100))%")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.oceanBase)
        }
        .frame(width: 52, height: 52)
        .accessibilityLabel("Community Trust")
        .accessibilityValue("\(Int(animatedTrust * 100)) percent")
    }

    // MARK: - Animate

    private func animateAll() {

        withAnimation(.easeInOut(duration: 0.6)) {
            animatedExchanges = Double(store.totalExchanges)
            animatedCirculated = Double(store.totalCirculated)
            animatedTrust = store.communityTrust
        }
    }
}
