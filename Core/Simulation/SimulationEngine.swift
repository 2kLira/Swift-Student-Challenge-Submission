//
//  SimulationEngine.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import Foundation
import SwiftUI

@MainActor
final class SimulationEngine: ObservableObject {

    // Progreso 0...1 controla toda la simulación
    @Published var progress: Double = 0 {
        didSet { apply(progress: progress) }
    }

    @Published private(set) var users: [SimUser] = []
    @Published private(set) var exchanges: [SimExchange] = []
    @Published private(set) var metrics: SimMetrics = .init(exchanges: 0, circulated: 0, trustIndex: 0, velocity: 0)

    // Estado base (punto 0)
    private let baseUsers: [SimUser] = [
        SimUser(name: "María", balance: 8, trust: 0.62, completed: 2),
        SimUser(name: "José",  balance: 5, trust: 0.58, completed: 1),
        SimUser(name: "Lupita",balance: 6, trust: 0.66, completed: 3)
    ]

    // Guion (eventos) — esto es “economía controlada”
    private let script: [SimExchange] = [
        SimExchange(title: "Childcare Support", detail: "Helping a neighbor with childcare.", tokens: 5, from: "María", to: "José"),
        SimExchange(title: "Tool Repair", detail: "Fixing agricultural tools.", tokens: 3, from: "José", to: "Lupita"),
        SimExchange(title: "Market Transport", detail: "Sharing a ride to the local market.", tokens: 4, from: "Lupita", to: "María")
    ]

    init() {
        self.users = baseUsers
        self.exchanges = []
        self.metrics = .init(exchanges: 0, circulated: 0, trustIndex: averageTrust(baseUsers), velocity: 0)
    }

    // MARK: - Core

    private func apply(progress p: Double) {
        let pClamped = min(max(p, 0), 1)

        // Fase continua: 0..1 mapea 0..script.count intercambios “graduales”
        let total = Double(script.count)
        let raw = pClamped * total

        let fullCount = Int(floor(raw))                 // intercambios completos
        let partial = raw - Double(fullCount)           // 0..1 del siguiente intercambio

        // 1) Reset a base
        var u = baseUsers
        var ex: [SimExchange] = []
        var circulated: Double = 0

        // 2) Aplica intercambios completos
        if fullCount > 0 {
            for i in 0..<min(fullCount, script.count) {
                let e = script[i]
                ex.append(e)
                circulated += e.tokens
                u = transfer(tokens: e.tokens, from: e.from, to: e.to, users: u)
                u = updateTrust(users: u, from: e.from, to: e.to, strength: 0.06) // confianza sube un poco
                u = incrementCompleted(users: u, name: e.from)
                u = incrementCompleted(users: u, name: e.to)
            }
        }

        // 3) Aplica intercambio parcial (solo para interpolación suave)
        if fullCount < script.count {
            let e = script[fullCount]

            // La card aparece con “partial”
            let eased = easeInOut(partial)
            let tokensMoved = e.tokens * eased

            // Clona exchange con tokens “visuales” parciales (para UI)
            let partialExchange = SimExchange(
                title: e.title,
                detail: e.detail,
                tokens: tokensMoved,
                from: e.from,
                to: e.to
            )

            // Si hay avance, lo mostramos como último elemento (sin contarlo como completo)
            if eased > 0.02 {
                ex.append(partialExchange)
            }

            circulated += tokensMoved
            u = transfer(tokens: tokensMoved, from: e.from, to: e.to, users: u)
            u = updateTrust(users: u, from: e.from, to: e.to, strength: 0.06 * eased)
        }

        // 4) Métricas
        let trustIndex = averageTrust(u)
        let velocity = circulated / max(totalSupply(baseUsers), 1) // métrica simple

        self.users = u
        self.exchanges = ex
        self.metrics = .init(
            exchanges: min(fullCount, script.count), // completos
            circulated: circulated,
            trustIndex: trustIndex,
            velocity: velocity
        )
    }

    // MARK: - Helpers

    private func transfer(tokens: Double, from: String, to: String, users: [SimUser]) -> [SimUser] {
        var u = users
        guard let iFrom = u.firstIndex(where: { $0.name == from }),
              let iTo   = u.firstIndex(where: { $0.name == to }) else { return u }

        u[iFrom].balance = max(u[iFrom].balance - tokens, 0)
        u[iTo].balance += tokens
        return u
    }

    private func updateTrust(users: [SimUser], from: String, to: String, strength: Double) -> [SimUser] {
        var u = users
        for idx in u.indices {
            if u[idx].name == from || u[idx].name == to {
                u[idx].trust = min(max(u[idx].trust + strength, 0), 1)
            }
        }
        return u
    }

    private func incrementCompleted(users: [SimUser], name: String) -> [SimUser] {
        var u = users
        if let idx = u.firstIndex(where: { $0.name == name }) {
            u[idx].completed += 1
        }
        return u
    }

    private func averageTrust(_ users: [SimUser]) -> Double {
        guard !users.isEmpty else { return 0 }
        return users.map(\.trust).reduce(0, +) / Double(users.count)
    }

    private func totalSupply(_ users: [SimUser]) -> Double {
        users.map(\.balance).reduce(0, +)
    }

    private func easeInOut(_ t: Double) -> Double {
        // suave estilo Apple (sin librerías)
        return t < 0.5 ? 2*t*t : 1 - pow(-2*t + 2, 2)/2
    }
}
