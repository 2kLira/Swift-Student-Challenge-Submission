//
//  AddTaskView.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import SwiftUI

struct AddTruequeView: View {
    
    @ObservedObject var store: TruequeStore
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var tokens = ""
    
    var body: some View {
        
        NavigationView {
            
            VStack(spacing: 20) {
                
                TextField("Title", text: $title)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Description", text: $description)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Tokens", text: $tokens)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Trueque")
            .toolbar {
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let tokenValue = Int(tokens) {
                            store.addTrueque(
                                title: title,
                                description: description,
                                tokens: tokenValue
                            )
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
