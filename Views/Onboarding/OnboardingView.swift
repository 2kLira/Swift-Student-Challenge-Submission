//
//  OnboardingView.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 23/02/26.
//

import SwiftUI

struct OnboardingView: View {

    var onFinish: () -> Void

    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var stage = 0
    @State private var animateNetwork = false
    @State private var animateTrust = false

    var body: some View {

        ZStack {

            Color.backgroundSand.ignoresSafeArea()

            if sizeClass == .regular {
                ipadLayout
            } else {
                iphoneLayout
            }
        }
        .onTapGesture {
            nextStage()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                stage = 0
            }
        }
    }
}

//////////////////////////////////////////////////////////////
// MARK: - Layouts
//////////////////////////////////////////////////////////////

extension OnboardingView {

    private var ipadLayout: some View {

        VStack(spacing: 60) {

            Spacer()

            content
                .frame(maxWidth: 720)

            Spacer()

            if stage == 2 {
                startButton
            }
        }
        .padding(.horizontal, 80)
    }

    private var iphoneLayout: some View {

        VStack(spacing: 40) {

            Spacer()

            content

            Spacer()

            if stage == 2 {
                startButton
            }
        }
        .padding(40)
    }
}

//////////////////////////////////////////////////////////////
// MARK: - Content by Stage
//////////////////////////////////////////////////////////////

extension OnboardingView {

    @ViewBuilder
    private var content: some View {

        switch stage {

        case 0:
            VStack(spacing: 20) {

                Text("I grew up watching communities full of talent")
                    .font(.system(size: sizeClass == .regular ? 34 : 24, weight: .medium))
                    .multilineTextAlignment(.center)

                Text("with no real opportunity to grow.")
                    .font(.system(size: sizeClass == .regular ? 20 : 16))
                    .foregroundColor(.oceanBase.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .transition(.opacity)

        case 1:
            VStack(spacing: 28) {

                Text("Value already exists inside communities.")
                    .font(.system(size: sizeClass == .regular ? 30 : 22, weight: .medium))
                    .multilineTextAlignment(.center)

                Text("It just needs structure to circulate.")
                    .font(.system(size: sizeClass == .regular ? 18 : 16))
                    .foregroundColor(.oceanBase.opacity(0.7))
                    .multilineTextAlignment(.center)

                SimpleNetworkView(animate: animateNetwork, large: sizeClass == .regular)
                    .frame(height: sizeClass == .regular ? 260 : 180)
                    .padding(.top, 30)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2)) {
                    animateNetwork = true
                }
            }
            .transition(.opacity)

        default:
            VStack(spacing: 30) {

                Text("What if trust itself")
                    .font(.system(size: sizeClass == .regular ? 34 : 24, weight: .medium))
                    .multilineTextAlignment(.center)

                Text("could become currency?")
                    .font(.system(size: sizeClass == .regular ? 20 : 16))
                    .foregroundColor(.oceanBase.opacity(0.7))
                    .multilineTextAlignment(.center)

                TrustPreviewRing(
                    animate: animateTrust,
                    large: sizeClass == .regular
                )
                .frame(
                    width: sizeClass == .regular ? 140 : 80,
                    height: sizeClass == .regular ? 140 : 80
                )
                .padding(.top, 30)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2)) {
                    animateTrust = true
                }
            }
            .transition(.opacity)
        }
    }
}

//////////////////////////////////////////////////////////////
// MARK: - Button
//////////////////////////////////////////////////////////////

extension OnboardingView {

    private var startButton: some View {

        Button(action: onFinish) {
            Text("Start Community →")
                .font(.system(size: sizeClass == .regular ? 20 : 17, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, sizeClass == .regular ? 40 : 24)
                .padding(.vertical, sizeClass == .regular ? 16 : 12)
                .background(Color.oceanAccent)
                .clipShape(Capsule())
        }
        .transition(.opacity)
    }

    private func nextStage() {
        withAnimation(.easeInOut(duration: 0.6)) {
            if stage < 2 {
                stage += 1
            }
        }
    }
}

//////////////////////////////////////////////////////////////
// MARK: - Simple Network
//////////////////////////////////////////////////////////////

struct SimpleNetworkView: View {

    var animate: Bool
    var large: Bool = false

    var body: some View {

        GeometryReader { geo in

            let center = CGPoint(
                x: geo.size.width / 2,
                y: geo.size.height / 2
            )

            let offset: CGFloat = large ? 100 : 60
            let nodeSize: CGFloat = large ? 26 : 16

            ZStack {

                Circle()
                    .fill(Color.oceanBase)
                    .frame(width: large ? 28 : 20)
                    .position(center)

                Circle()
                    .fill(Color.oceanBase)
                    .frame(width: nodeSize)
                    .position(x: center.x - offset, y: center.y + offset * 0.5)

                Circle()
                    .fill(Color.oceanBase)
                    .frame(width: nodeSize)
                    .position(x: center.x + offset, y: center.y - offset * 0.3)

                Path { p in
                    p.move(to: center)
                    p.addLine(to: CGPoint(x: center.x - offset, y: center.y + offset * 0.5))
                    p.move(to: center)
                    p.addLine(to: CGPoint(x: center.x + offset, y: center.y - offset * 0.3))
                }
                .stroke(
                    Color.oceanAccent.opacity(animate ? 0.6 : 0.0),
                    lineWidth: large ? 3 : 2
                )
                .animation(.easeInOut(duration: 1.2), value: animate)
            }
        }
    }
}

//////////////////////////////////////////////////////////////
// MARK: - Trust Ring
//////////////////////////////////////////////////////////////

struct TrustPreviewRing: View {

    var animate: Bool
    var large: Bool = false

    var body: some View {

        ZStack {

            Circle()
                .stroke(Color.oceanBase.opacity(0.15), lineWidth: large ? 10 : 6)

            Circle()
                .trim(from: 0, to: animate ? 0.65 : 0)
                .stroke(
                    Color.oceanAccent,
                    style: StrokeStyle(
                        lineWidth: large ? 10 : 6,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.2), value: animate)
        }
    }
}
