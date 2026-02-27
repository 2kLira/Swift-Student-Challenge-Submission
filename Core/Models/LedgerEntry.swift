//
//  LedgerEntry.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import Foundation

struct LedgerEntry: Identifiable {
    let id: UUID
    let fromUser: UUID
    let toUser: UUID
    let tokens: Int
    let taskID: UUID
    let date: Date
    
    init(fromUser: UUID,
         toUser: UUID,
         tokens: Int,
         taskID: UUID) {
        
        self.id = UUID()
        self.fromUser = fromUser
        self.toUser = toUser
        self.tokens = tokens
        self.taskID = taskID
        self.date = Date()
    }
}
