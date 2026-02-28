//
//  CommunityNetworkView.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 23/02/26.
//


import SwiftUI
import MapKit

struct CommunityNetworkView: View {

    @ObservedObject var store: TruequeStore
    @EnvironmentObject var accessibility: AccessibilityManager
    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var animatePulse = false
    @State private var lastLedgerCount = 0

    // Región corregida (360 NO es válido)
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 15, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 180)
    )

    @State private var rotationTimer: Timer?

    var body: some View {

        ZStack {

            worldMapBackground

            if sizeClass == .regular {
                ipadLayout
            } else {
                iphoneLayout
            }
        }
        .onAppear {
            startContinuousRotation()
        }
        .onDisappear {
            rotationTimer?.invalidate()
        }
    }
}

// World Map Background

extension CommunityNetworkView {

    private var worldMapBackground: some View {

        Map(coordinateRegion: $region, interactionModes: [])
            .ignoresSafeArea()
            .overlay(
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.45),
                        Color.black.opacity(0.25)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }

    // Rotation
    private func startContinuousRotation() {

        guard !accessibility.reduceMotionMode else { return }

        rotationTimer?.invalidate()

        rotationTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in

            DispatchQueue.main.async {
                region.center.longitude += 0.04

                if region.center.longitude > 180 {
                    region.center.longitude = -180
                }
            }
        }
    }
}

// Layouts

extension CommunityNetworkView {

    private var ipadLayout: some View {

        VStack(spacing: 24) {

            headerMetrics
                .frame(maxWidth: 1000)

            GeometryReader { geo in
                networkCanvas(in: geo.size)
                    .frame(maxWidth: 1100)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(.horizontal, 40)
        .padding(.top, 10)
    }

    private var iphoneLayout: some View {

        VStack(spacing: 14) {

            headerMetrics

            GeometryReader { geo in
                networkCanvas(in: geo.size)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 12)

            Spacer(minLength: 8)
        }
    }
}

extension CommunityNetworkView {

    private func networkCanvas(in size: CGSize) -> some View {

        let users = store.selectedCommunity?.users ?? []
        let positions = organicCirclePositions(users: users, in: size)
        let connections = store.ledger

        return ZStack {

            ForEach(connections) { e in
                if let p1 = positions[e.fromUser],
                   let p2 = positions[e.toUser] {

                    NetworkEdge(
                        from: p1,
                        to: p2,
                        tokens: e.tokens,
                        trust: store.communityTrust,
                        pulse: animatePulse,
                        reduceMotion: accessibility.reduceMotionMode
                    )
                }
            }

            ForEach(users) { u in
                if let p = positions[u.id] {
                    NetworkNode(
                        name: u.name,
                        balance: u.tokenBalance,
                        trust: store.communityTrust,
                        reduceMotion: accessibility.reduceMotionMode
                    )
                    .position(p)
                }
            }
        }
        .onChange(of: store.ledger.count) { newCount in
            if newCount > lastLedgerCount {
                triggerPulse()
            }
            lastLedgerCount = newCount
        }
        .onAppear {
            lastLedgerCount = store.ledger.count
        }
    }
}

extension CommunityNetworkView {

    private var headerMetrics: some View {

        VStack(spacing: 14) {

            HStack {
                Text("Community Network")
                    .font(.system(size: sizeClass == .regular ? 20 : 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))

                Spacer()

                Text("\(Int(store.communityTrust * 100))% Trust")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.cyan)
            }

            HStack(spacing: 16) {
                metricChip(title: "Exchanges", value: "\(store.totalExchanges)")
                metricChip(title: "Circulated", value: "\(store.totalCirculated) TT")
                metricChip(title: "People", value: "\(store.selectedCommunity?.users.count ?? 0)")
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }

    private func metricChip(title: String, value: String) -> some View {

        VStack(alignment: .leading, spacing: 4) {

            Text(value)
                .font(.system(size: sizeClass == .regular ? 18 : 15, weight: .semibold))
                .foregroundColor(.white)

            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.glassBorder, lineWidth: 1)
        )
        .frame(maxWidth: .infinity)
    }
}

extension CommunityNetworkView {

    private func organicCirclePositions(users: [User], in size: CGSize) -> [UUID: CGPoint] {

        let n = max(users.count, 1)
        let center = CGPoint(x: size.width * 0.5, y: size.height * 0.55)

        // Ajuste leve para mapa
        let multiplier: CGFloat = sizeClass == .regular ? 0.32 : 0.26
        let baseRadius = min(size.width, size.height) * multiplier

        let angleStep = (2 * Double.pi) / Double(n)

        var dict: [UUID: CGPoint] = [:]

        for (i, u) in users.enumerated() {

            let h = stableHash(u.id.uuidString)

            let angleJitter = map01ToRange(h.a, -0.11, 0.11)
            let radiusJitterFactor = map01ToRange(h.b, -0.14, 0.14)

            let angle = (Double(i) * angleStep) + angleJitter
            let radius = baseRadius * (1.0 + radiusJitterFactor)

            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius

            dict[u.id] = CGPoint(x: x, y: y)
        }

        return dict
    }

    private func triggerPulse() {

        guard !accessibility.reduceMotionMode else { return }

        animatePulse = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            animatePulse = false
        }
    }

    private struct HashPair {
        let a: Double
        let b: Double
    }

    private func stableHash(_ s: String) -> HashPair {

        var total1: UInt64 = 0
        var total2: UInt64 = 1469598103934665603

        for scalar in s.unicodeScalars {
            total1 &+= UInt64(scalar.value) * 1315423911
            total2 ^= UInt64(scalar.value)
            total2 &*= 1099511628211
        }

        let a = Double(total1 % 10_000) / 10_000.0
        let b = Double(total2 % 10_000) / 10_000.0
        return HashPair(a: a, b: b)
    }

    private func map01ToRange(_ x: Double, _ minV: Double, _ maxV: Double) -> Double {
        minV + (maxV - minV) * x
    }
}

private struct NetworkEdge: View {

    let from: CGPoint
    let to: CGPoint
    let tokens: Int
    let trust: Double
    let pulse: Bool
    let reduceMotion: Bool

    var body: some View {

        Path { p in
            p.move(to: from)
            p.addLine(to: to)
        }
        .stroke(
            Color.red.opacity(edgeOpacity),
            style: StrokeStyle(
                lineWidth: edgeWidth,
                lineCap: .round,
                lineJoin: .round
            )
        )
        .shadow(
            color: Color.red.opacity(pulse ? 0.30 : 0.12),
            radius: pulse ? 14 : 6
        )
        .animation(
            reduceMotion ? nil :
                .spring(response: 0.35, dampingFraction: 0.75),
            value: pulse
        )
    }

    private var edgeWidth: CGFloat {
        let base: CGFloat = 2.5
        let variable = CGFloat(min(tokens, 12)) * 0.4
        return min(base + variable, 8.0)
    }

    private var edgeOpacity: Double {
        0.45 + trust * 0.4
    }
}

private struct NetworkNode: View {

    let name: String
    let balance: Int
    let trust: Double
    let reduceMotion: Bool

    var body: some View {

        VStack(spacing: 6) {

            Text(name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)

            Text("\(balance) TT")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.glassBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 8)
        .scaleEffect(nodeScale)
        .animation(
            reduceMotion ? nil :
                .spring(response: 0.35, dampingFraction: 0.8),
            value: trust
        )
    }

    private var nodeScale: CGFloat {
        let s = 0.98 + CGFloat(trust) * 0.04
        return min(max(s, 0.98), 1.02)
    }
}
