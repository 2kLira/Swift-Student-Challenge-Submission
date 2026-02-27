//
//  Task.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import Foundation

struct Task: Identifiable {

    let id = UUID()
    var title: String
    var details: String
    var offeredTokens: Int
}
