//
//  CounterOfferView.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 18/02/26.
//


import SwiftUI
import UIKit

struct CounterOfferView: View {
    
    var trueque: Trueque
    var onApply: (Int) -> Void
    
    @EnvironmentObject var accessibility: AccessibilityManager
    
    @State private var value: Int
    
    init(trueque: Trueque, onApply: @escaping (Int) -> Void) {
        self.trueque = trueque
        self.onApply = onApply
        _value = State(initialValue: trueque.tokens)
    }
    
    var body: some View {
        
        VStack(spacing: 30) {
            
            Text("Counter Offer")
                .font(.title3)
                .fontWeight(.semibold)
            
            HStack(spacing: 24) {
                
                Button {
                    decrement()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundColor(.oceanAccent)
                }
                .accessibilityLabel("Decrease tokens")
                
                Text("\(value) TT")
                    .font(.title2)
                    .fontWeight(.medium)
                    .minimumScaleFactor(0.7)
                    .accessibilityLabel("Current token value \(value)")
                
                Button {
                    increment()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.oceanAccent)
                }
                .accessibilityLabel("Increase tokens")
            }
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text("Tokens")
                    .font(.caption)
                    .foregroundColor(.oceanBase.opacity(0.6))
                
                TextField("Amount", value: $value, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .font(.body)
                    .accessibilityLabel("Token amount field")
            }
            .frame(maxWidth: 200)
            
            Button("Apply Counter") {
                onApply(value)
            }
            .font(.body)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(Color.oceanAccent.opacity(0.2))
            .clipShape(Capsule())
            .accessibilityLabel("Apply counter offer")
        }
        .padding()
        .dynamicTypeSize(.xSmall ... .accessibility5)
    }
    
    private func increment() {
        value += 1
        microHaptic()
    }
    
    private func decrement() {
        if value > 0 {
            value -= 1
            microHaptic()
        }
    }
    
    private func microHaptic() {
        guard !accessibility.reduceMotionMode else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
}
