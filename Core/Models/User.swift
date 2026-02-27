//
//  User.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import Foundation

struct User: Identifiable {
    let id = UUID()
    let name: String
    var tokenBalance: Int
}
