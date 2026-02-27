//
//  Negotiation.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import Foundation

struct Negotiation: Identifiable {
    let id: UUID
    let taskID: UUID
    let proposerID: UUID
    var proposedTokens: Int
    var isAccepted: Bool
    
    init(taskID: UUID,
         proposerID: UUID,
         proposedTokens: Int) {
        
        self.id = UUID()
        self.taskID = taskID
        self.proposerID = proposerID
        self.proposedTokens = proposedTokens
        self.isAccepted = false
    }
}
