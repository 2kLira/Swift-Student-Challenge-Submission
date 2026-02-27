//
//  AccessibilitySettingsView.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 24/02/26.
//


import SwiftUI

struct AccessibilitySettingsView: View {
    
    @Environment(\.accessibilityVoiceOverEnabled) var voiceOverEnabled
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    @AppStorage("accessibleMode") private var accessibleMode = false
    @AppStorage("largeTextMode") private var largeTextMode = false
    @AppStorage("highContrastMode") private var highContrastMode = false
    @AppStorage("reduceMotionMode") private var reduceMotionMode = false
    
    var body: some View {
        
        ZStack {
            backgroundView
            contentLayout
                .padding(40)
        }
        .navigationTitle("Accessibility")
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
        HStack(alignment: .top, spacing: 60) {
            visualColumn
            screenReaderColumn
        }
    }
    
    private var iphoneLayout: some View {
        VStack(spacing: 30) {
            visualColumn
            screenReaderColumn
        }
    }
}

// MARK: - Columns

extension AccessibilitySettingsView {
    
    private var visualColumn: some View {
        VStack(alignment: .leading, spacing: 30) {
            
            sectionHeader("Visual Settings")
            
            ToggleRow(
                title: "Accessible Mode",
                description: "Simplifies layout and increases spacing.",
                isOn: $accessibleMode
            )
            
            ToggleRow(
                title: "Large Text",
                description: "Increases font size across the app.",
                isOn: $largeTextMode
            )
            
            ToggleRow(
                title: "High Contrast",
                description: "Enhances foreground/background contrast.",
                isOn: $highContrastMode
            )
            
            ToggleRow(
                title: "Reduce Motion",
                description: "Minimizes animations and transitions.",
                isOn: $reduceMotionMode
            )
        }
    }
    
    private var screenReaderColumn: some View {
        VStack(alignment: .leading, spacing: 30) {
            
            sectionHeader("Screen Reader")
            
            HStack(spacing: 15) {
                
                Image(systemName: voiceOverEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .font(.title2)
                    .foregroundColor(voiceOverEnabled ? .green : .secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text("VoiceOver")
                        .font(.headline)
                    
                    Text(
                        voiceOverEnabled
                        ? "VoiceOver is currently enabled."
                        : "VoiceOver is managed in system settings."
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                voiceOverEnabled
                ? "VoiceOver is enabled."
                : "VoiceOver is disabled. Controlled by system settings."
            )
        }
    }
}

// MARK: - Helpers

extension AccessibilitySettingsView {
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 24, weight: .semibold))
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                highContrastMode ? .black : Color.backgroundSand,
                highContrastMode ? .black : Color.white.opacity(0.95)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - ToggleRow Component

struct ToggleRow: View {
    
    var title: String
    var description: String
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $isOn)
                    .labelsHidden()
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(description)")
        .accessibilityValue(isOn ? "Enabled" : "Disabled")
    }
}