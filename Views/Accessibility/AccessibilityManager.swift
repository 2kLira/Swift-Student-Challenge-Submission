//
//  AccessibilityManager.swift
//  TruequeTide_ Submission
//
//  Created by Guillermo Lira on 26/02/26.
//


import SwiftUI

final class AccessibilityManager: ObservableObject {

    @AppStorage("accessibleMode") var accessibleMode = false
    @AppStorage("largeTextMode") var largeTextMode = false
    @AppStorage("highContrastMode") var highContrastMode = false
    @AppStorage("reduceMotionMode") var reduceMotionMode = false
}