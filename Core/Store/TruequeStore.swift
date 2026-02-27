//
//  TruequeStore.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import Foundation
import UIKit

final class TruequeStore: ObservableObject {

    // MARK: - Initial Config

    private let initialTokens: Int = 10

    @Published var communities: [Community] = [
        Community(name: "Zapotec"),
        Community(name: "Mixtec"),
        Community(name: "Mazatec")
    ]

    @Published var selectedCommunity: Community?
    @Published var selectedUser: User?

    @Published private(set) var ledger: [LedgerEntry] = []

    @Published private(set) var totalExchanges: Int = 0
    @Published private(set) var totalCirculated: Int = 0
    @Published private(set) var communityTrust: Double = 0.45

    // MARK: - Select Community

    func selectCommunity(_ community: Community) {

        selectedCommunity = community

        switch community.name {

        case "Zapotec":

            let names = ["Aurelio", "Ximena", "Xhunashi"]
            selectedCommunity?.users = names.map {
                User(name: $0, tokenBalance: initialTokens)
            }

            selectedCommunity?.trueques = [
                Trueque(title: "Carpenter Work",
                        description: "Repairing wooden doors.",
                        tokens: 6,
                        owner: "Aurelio"),

                Trueque(title: "Childcare Support",
                        description: "Helping neighbors with kids.",
                        tokens: 3,
                        owner: "Ximena"),

                Trueque(title: "Corn Milling",
                        description: "Grinding maize locally.",
                        tokens: 4,
                        owner: "Xhunashi")
            ]

        case "Mixtec":

            let names = ["Yaretzi", "Itzel", "Gael"]
            selectedCommunity?.users = names.map {
                User(name: $0, tokenBalance: initialTokens)
            }

            selectedCommunity?.trueques = [
                Trueque(title: "Grass Cutting",
                        description: "Field maintenance.",
                        tokens: 4,
                        owner: "Yaretzi"),

                Trueque(title: "Water Delivery",
                        description: "Transporting clean water.",
                        tokens: 5,
                        owner: "Itzel"),

                Trueque(title: "Basic Healthcare",
                        description: "Community health assistance.",
                        tokens: 7,
                        owner: "Gael")
            ]

        case "Mazatec":

            let names = ["Citlali", "Vi", "Banhi"]
            selectedCommunity?.users = names.map {
                User(name: $0, tokenBalance: initialTokens)
            }

            selectedCommunity?.trueques = [
                Trueque(title: "Community Cooking",
                        description: "Preparing meals.",
                        tokens: 5,
                        owner: "Citlali"),

                Trueque(title: "Maize Grinding",
                        description: "Traditional milling.",
                        tokens: 4,
                        owner: "Vi"),

                Trueque(title: "Childcare Evening",
                        description: "After school supervision.",
                        tokens: 3,
                        owner: "Banhi")
            ]

        default:
            selectedCommunity?.users = []
            selectedCommunity?.trueques = []
        }

        syncCommunity()
        selectedUser = nil

        ledger.removeAll()
        totalExchanges = 0
        totalCirculated = 0
        communityTrust = 0.45
    }

    func selectUser(_ user: User) {
        selectedUser = user
    }

    // MARK: - Add Trueque

    func addTrueque(title: String, description: String, tokens: Int) {

        guard let user = selectedUser else { return }
        guard tokens >= 0 else { return }

        let newTrueque = Trueque(
            title: title,
            description: description,
            tokens: tokens,
            owner: user.name
        )

        selectedCommunity?.trueques.append(newTrueque)
        syncCommunity()
    }

    // MARK: - Apply Counter

    func applyCounter(truequeID: UUID, newValue: Int) {

        guard newValue >= 0 else { return }
        guard var community = selectedCommunity else { return }
        guard let currentUser = selectedUser else { return }

        guard let index = community.trueques.firstIndex(where: { $0.id == truequeID }) else { return }

        community.trueques[index].tokens = newValue
        community.trueques[index].status = .countered
        community.trueques[index].lastCounterBy = currentUser.name

        selectedCommunity = community
        syncCommunity()
        refreshUser()
    }

    // MARK: - Accept

    func acceptTrueque(truequeID: UUID) -> Bool {

        guard var community = selectedCommunity else { return false }
        guard let currentUser = selectedUser else { return false }

        guard let truequeIndex = community.trueques.firstIndex(where: { $0.id == truequeID }) else {
            return false
        }

        let trueque = community.trueques[truequeIndex]

        if trueque.owner == currentUser.name { return false }

        guard let payerIndex = community.users.firstIndex(where: { $0.name == currentUser.name }),
              let receiverIndex = community.users.firstIndex(where: { $0.name == trueque.owner })
        else { return false }

        let cost = trueque.tokens

        if community.users[payerIndex].tokenBalance < cost {
            return false
        }

        community.users[payerIndex].tokenBalance -= cost
        community.users[receiverIndex].tokenBalance += cost

        community.trueques[truequeIndex].status = .accepted

        let entry = LedgerEntry(
            fromUser: community.users[payerIndex].id,
            toUser: community.users[receiverIndex].id,
            tokens: cost,
            taskID: truequeID
        )

        ledger.insert(entry, at: 0)

        totalExchanges += 1
        totalCirculated += cost
        updateTrust()

        selectedCommunity = community
        syncCommunity()
        refreshUser()

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        return true
    }

    // MARK: - Reject

    func rejectTrueque(truequeID: UUID) {

        guard var community = selectedCommunity else { return }
        guard let index = community.trueques.firstIndex(where: { $0.id == truequeID }) else { return }

        community.trueques.remove(at: index)

        selectedCommunity = community
        syncCommunity()
        refreshUser()
    }

    // MARK: - Helpers

    func userName(for id: UUID) -> String {
        selectedCommunity?.users.first(where: { $0.id == id })?.name ?? "Unknown"
    }

    func reset() {
        selectedCommunity = nil
        selectedUser = nil
        ledger.removeAll()
        totalExchanges = 0
        totalCirculated = 0
        communityTrust = 0.45
    }

    // MARK: - Private

    private func updateTrust() {
        let base = 0.45
        let growth = Double(totalExchanges) * 0.035
        communityTrust = min(base + growth, 1.0)
    }

    private func syncCommunity() {
        guard let sc = selectedCommunity,
              let index = communities.firstIndex(where: { $0.name == sc.name }) else { return }
        communities[index] = sc
    }

    private func refreshUser() {
        guard let sc = selectedCommunity,
              let su = selectedUser,
              let updated = sc.users.first(where: { $0.name == su.name }) else { return }
        selectedUser = updated
    }
}
