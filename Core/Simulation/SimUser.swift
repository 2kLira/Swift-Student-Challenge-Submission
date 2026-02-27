//
//  SimUser.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import Foundation

struct SimUser: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var balance: Double
    var trust: Double       // 0...1
    var completed: Int
}

struct SimExchange: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var detail: String
    var tokens: Double
    var from: String
    var to: String
}

struct SimMetrics: Equatable {
    var exchanges: Int
    var circulated: Double
    var trustIndex: Double  // 0...1
    var velocity: Double    // 0... (simple)
}
