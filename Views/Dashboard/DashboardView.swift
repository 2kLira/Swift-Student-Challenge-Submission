//
//  DashboardView.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import SwiftUI
import UIKit

struct DashboardView: View {

    @ObservedObject var store: TruequeStore
    var reset: () -> Void

    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var counterTrueque: Trueque?
    @State private var showAddSheet = false
    @State private var showInsufficientBalanceAlert = false

    @State private var balancePulse = false

    @State private var showFloatingTT = false
    @State private var floatingText = ""
    @State private var floatingColor: Color = .oceanAccent
    @State private var floatingOffsetY: CGFloat = 0
    @State private var floatingScale: CGFloat = 1.0
    @State private var floatingOpacity: Double = 0

    var body: some View {

        ZStack(alignment: .topTrailing) {

            if sizeClass == .regular {
                ipadLayout
            } else {
                iphoneLayout
            }

            if showFloatingTT {
                floatingOverlay
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddTruequeView(store: store)
        }
        .sheet(item: $counterTrueque) { trueque in
            CounterOfferView(trueque: trueque) { newValue in
                store.applyCounter(truequeID: trueque.id, newValue: newValue)
                counterTrueque = nil
            }
        }
        .alert("Insufficient balance", isPresented: $showInsufficientBalanceAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You don’t have enough TT.")
        }
    }
}

//////////////////////////////////////////////////////////////
// MARK: - Layouts
//////////////////////////////////////////////////////////////

extension DashboardView {

    private var ipadLayout: some View {

        HStack(spacing: 32) {

            leftColumn
                .frame(maxWidth: 380)

            Divider()

            rightColumn
        }
        .padding(.horizontal, 40)
        .padding(.top, 10)
    }

    private var iphoneLayout: some View {

        VStack(spacing: 0) {

            header

            CommunityMetricsHeader(store: store)

            if let user = store.selectedUser {
                WalletMiniHistory(
                    entries: recentEntries(for: user),
                    titleFor: { store.userName(for: $0) }
                )
                .padding(.top, 2)
            }

            rightColumn
        }
    }

    private var leftColumn: some View {

        VStack(spacing: 20) {

            header

            CommunityMetricsHeader(store: store)

            if let user = store.selectedUser {
                WalletMiniHistory(
                    entries: recentEntries(for: user),
                    titleFor: { store.userName(for: $0) }
                )
            }

            Spacer()
        }
    }

    private var rightColumn: some View {

        ScrollView {
            VStack(spacing: 16) {

                if let community = store.selectedCommunity,
                   let user = store.selectedUser {

                    ForEach(community.trueques) { trueque in
                        TruequeCard(
                            trueque: trueque,
                            currentUser: user.name,
                            currentUserBalance: user.tokenBalance,
                            ownerBalance: balanceOfOwner(for: trueque),
                            onAccept: { acceptWithEffects(trueque: trueque) },
                            onReject: { store.rejectTrueque(truequeID: trueque.id) },
                            onCounter: { counterTrueque = trueque }
                        )
                    }

                } else {

                    Text("Missing selection.")
                        .foregroundColor(.gray)
                        .padding(.top, 40)
                }
            }
            .padding()
        }
    }
}

//////////////////////////////////////////////////////////////
// MARK: - Header
//////////////////////////////////////////////////////////////

extension DashboardView {

    private var header: some View {

        HStack {

            Button { reset() } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text("TRUEQUE TIDE")
                .font(.system(size: 16, weight: .medium))
                .tracking(2)

            Spacer()

            if let user = store.selectedUser {

                HStack(spacing: 6) {
                    Text("🫂")
                    Text("\(user.tokenBalance)")
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.oceanAccent)
                .scaleEffect(balancePulse ? 1.18 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: balancePulse)
                .onChange(of: user.tokenBalance) { _ in
                    triggerBalanceAnimation()
                }
            }

            Button { showAddSheet = true } label: {
                Image(systemName: "plus")
            }
        }
        .padding()
    }

    private func triggerBalanceAnimation() {
        balancePulse = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            balancePulse = false
        }
    }
}

//////////////////////////////////////////////////////////////
// MARK: - Floating TT
//////////////////////////////////////////////////////////////

extension DashboardView {

    private var floatingOverlay: some View {

        Text(floatingText)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(floatingColor)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(floatingColor.opacity(0.45), lineWidth: 1)
            )
            .opacity(floatingOpacity)
            .scaleEffect(floatingScale)
            .offset(x: -18, y: floatingOffsetY)
            .padding(.top, 10)
            .padding(.trailing, 52)
    }
}

//////////////////////////////////////////////////////////////
// MARK: - Logic
//////////////////////////////////////////////////////////////

extension DashboardView {

    private func acceptWithEffects(trueque: Trueque) {

        guard let user = store.selectedUser else { return }

        let before = user.tokenBalance
        let ok = store.acceptTrueque(truequeID: trueque.id)

        if !ok {
            showInsufficientBalanceAlert = true
            return
        }

        let after = store.selectedUser?.tokenBalance ?? before
        let delta = after - before

        floatingText = delta >= 0 ? "+\(delta) TT" : "\(delta) TT"
        floatingColor = delta >= 0 ? .green : .red

        playFloatingTTAnimation()
    }

    private func playFloatingTTAnimation() {

        showFloatingTT = true
        floatingOffsetY = 52
        floatingScale = 0.95
        floatingOpacity = 0

        withAnimation(.easeOut(duration: 0.18)) {
            floatingOpacity = 1
            floatingScale = 1.0
        }

        withAnimation(.easeInOut(duration: 0.65)) {
            floatingOffsetY = 0
        }

        withAnimation(.easeIn(duration: 0.55).delay(0.10)) {
            floatingOpacity = 0
            floatingScale = 0.85
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            showFloatingTT = false
        }
    }

    private func balanceOfOwner(for trueque: Trueque) -> Int {
        store.selectedCommunity?
            .users
            .first(where: { $0.name == trueque.owner })?
            .tokenBalance ?? 0
    }

    private func recentEntries(for user: User) -> [LedgerEntry] {
        Array(
            store.ledger
                .filter { $0.fromUser == user.id || $0.toUser == user.id }
                .prefix(6)
        )
    }
}

//////////////////////////////////////////////////////////////
// MARK: - Wallet Mini History
//////////////////////////////////////////////////////////////

private struct WalletMiniHistory: View {

    let entries: [LedgerEntry]
    let titleFor: (UUID) -> String

    var body: some View {

        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text("Activity")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.oceanBase.opacity(0.75))
                Spacer()
            }
            .padding(.horizontal)

            if entries.isEmpty {

                Text("No transactions yet.")
                    .font(.caption)
                    .foregroundColor(.oceanBase.opacity(0.5))
                    .padding(.horizontal)

            } else {

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(entries) { e in
                            WalletEntryCard(
                                entry: e,
                                fromName: titleFor(e.fromUser),
                                toName: titleFor(e.toUser)
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.bottom, 6)
    }
}

private struct WalletEntryCard: View {

    let entry: LedgerEntry
    let fromName: String
    let toName: String

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text("\(entry.tokens) TT")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.oceanAccent)

                Spacer()

                Text(shortDate(entry.date))
                    .font(.caption2)
                    .foregroundColor(.oceanBase.opacity(0.55))
            }

            Text("From: \(fromName)")
                .font(.caption)
                .foregroundColor(.oceanBase.opacity(0.75))

            Text("To: \(toName)")
                .font(.caption)
                .foregroundColor(.oceanBase.opacity(0.75))
        }
        .padding(14)
        .frame(width: 210)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.glassBorder, lineWidth: 1)
        )
    }

    private func shortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }
}
