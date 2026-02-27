//
//  AccessibilitySettingsView.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 24/02/26.
//


import SwiftUI

struct AccessibilitySettingsView: View {
    
    @EnvironmentObject var accessibility: AccessibilityManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                backgroundView
                
                contentLayout
                    .padding(sizeClass == .regular ? 60 : 30)
            }
            .navigationTitle("Accessibility")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Layout

extension AccessibilitySettingsView {
    
    @ViewBuilder
    private var contentLayout: some View {
        
        if sizeClass == .regular {
            ipadLayout
        } else {
            iphoneLayout
        }
    }
    
    private var ipadLayout: some View {
        HStack {
            Spacer()
            mainContent
                .frame(maxWidth: 500)
            Spacer()
        }
    }
    
    private var iphoneLayout: some View {
        mainContent
    }
}

// MARK: - Content

extension AccessibilitySettingsView {
    
    private var mainContent: some View {
        
        VStack(spacing: 36) {
            
            Toggle("Reduce Motion", isOn: $accessibility.reduceMotionMode)
                .font(.system(size: 17, weight: .medium))
                .accessibilityHint("Disables non-essential animations")
            
            VStack(spacing: 8) {
                
                Text("VoiceOver Fully Supported")
                    .font(.system(size: 16, weight: .medium))
                
                Text("Semantic grouping and dynamic announcements enabled.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .accessibilityElement(children: .combine)
            
            Spacer()
        }
    }
}

// MARK: - Background

extension AccessibilitySettingsView {
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color.backgroundSand,
                Color.white.opacity(0.95)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
