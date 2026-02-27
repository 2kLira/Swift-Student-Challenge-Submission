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
    
    @State private var value: Int
    
    init(trueque: Trueque, onApply: @escaping (Int) -> Void) {
        self.trueque = trueque
        self.onApply = onApply
        _value = State(initialValue: trueque.tokens)
    }
    
    var body: some View {
        
        VStack(spacing: 30) {
            
            Text("Counter Offer")
                .font(.headline)
            
            HStack(spacing: 20) {
                
                Button {
                    decrement()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.oceanAccent)
                }
                
                Text("\(value) TT")
                    .font(.system(size: 28, weight: .medium))
                    .frame(minWidth: 120)
                
                Button {
                    increment()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.oceanAccent)
                }
            }
            
            TextField("Tokens", value: $value, format: .number)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)
            
            Button("Apply Counter") {
                onApply(value)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 10)
            .background(Color.oceanAccent.opacity(0.2))
            .clipShape(Capsule())
        }
        .padding()
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
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
