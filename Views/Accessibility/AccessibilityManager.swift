//
//  AccessibilityManager.swift
//  TruequeTide_ Submission
//
//  Created by Guillermo Lira on 26/02/26.
//


import SwiftUI

@MainActor
final class AccessibilityManager: ObservableObject {
    
    @AppStorage("reduceMotionMode")
    var reduceMotionMode: Bool = false {
        willSet {
            objectWillChange.send()
        }
    }
    
    // MARK: - Computed Helpers
    
    var animationsEnabled: Bool {
        !reduceMotionMode
    }
}
