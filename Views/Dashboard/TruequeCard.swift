//
//  TruequeCard.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import SwiftUI
import UIKit

struct TruequeCard: View {

    var trueque: Trueque
    var currentUser: String
    var currentUserBalance: Int
    var ownerBalance: Int

    var onAccept: () -> Void
    var onReject: () -> Void
    var onCounter: () -> Void

    private var canAfford: Bool {
        currentUserBalance >= trueque.tokens
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 14) {

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trueque.title)
                        .font(.headline)

                    Text(trueque.description)
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("Owner Balance: \(ownerBalance) TT")
                        .font(.caption2)
                        .foregroundColor(.oceanBase.opacity(0.6))
                }

                Spacer()

                Text("\(trueque.tokens) TT")
                    .font(.subheadline)
                    .foregroundColor(.oceanAccent)
            }

            statusSection
        }
        .padding()
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.05), radius: 8)
        .animation(.easeInOut(duration: 0.25), value: trueque.status)
    }

    private var backgroundColor: Color {
        switch trueque.status {
        case .countered:
            return Color.orange.opacity(0.08)
        default:
            return Color.white
        }
    }

    @ViewBuilder
    private var statusSection: some View {

        if trueque.owner == currentUser {

            HStack {
                Text("Your Trueque")
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()

                statusBadge
            }

        } else {

            switch trueque.status {

            case .active:
                HStack(spacing: 10) {

                    glassButton(
                        title: "Accept",
                        color: .green,
                        disabled: !canAfford
                    ) {
                        onAccept()
                    }

                    glassButton(
                        title: "Counter",
                        color: .orange,
                        disabled: false
                    ) {
                        onCounter()
                    }

                    glassButton(
                        title: "Reject",
                        color: .red,
                        disabled: false
                    ) {
                        onReject()
                    }
                }

            case .countered:
                HStack(spacing: 10) {

                    statusBadge

                    Spacer()

                    glassButton(
                        title: "Accept",
                        color: .green,
                        disabled: !canAfford
                    ) {
                        onAccept()
                    }

                    glassButton(
                        title: "Reject",
                        color: .red,
                        disabled: false
                    ) {
                        onReject()
                    }
                }

            case .accepted, .rejected:
                statusBadge
            }
        }
    }

    private func glassButton(
        title: String,
        color: Color,
        disabled: Bool,
        action: @escaping () -> Void
    ) -> some View {

        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(
                    .ultraThinMaterial
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(color.opacity(0.6), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .foregroundColor(color)
                .opacity(disabled ? 0.4 : 1)
        }
        .disabled(disabled)
    }

    private var statusBadge: some View {

        Group {
            switch trueque.status {

            case .countered:
                Text("Countered")
                    .foregroundColor(.orange)

            case .accepted:
                Text("Accepted")
                    .foregroundColor(.green)

            case .rejected:
                Text("Rejected")
                    .foregroundColor(.red)

            default:
                EmptyView()
            }
        }
        .font(.caption)
    }
}
