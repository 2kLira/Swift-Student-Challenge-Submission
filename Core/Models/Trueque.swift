//
//  Trueque.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import Foundation

struct Trueque: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var tokens: Int
    var owner: String
    var status: TruequeStatus = .active
    var lastCounterBy: String? = nil
}
