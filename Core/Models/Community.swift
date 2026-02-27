//
//  Community.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import Foundation

struct Community: Identifiable {
    
    let id = UUID()
    var name: String
    
    var users: [User] = []
    var trueques: [Trueque] = []
}
