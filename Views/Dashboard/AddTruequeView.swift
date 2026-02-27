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
    @EnvironmentObject var accessibility: AccessibilityManager
    
    @State private var title = ""
    @State private var description = ""
    @State private var tokens = ""
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .leading, spacing: 24) {
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("Title")
                        .font(.caption)
                        .foregroundColor(.oceanBase.opacity(0.6))
                    
                    TextField("Enter title", text: $title)
                        .textFieldStyle(.roundedBorder)
                        .font(.body)
                        .accessibilityLabel("Trueque title")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("Description")
                        .font(.caption)
                        .foregroundColor(.oceanBase.opacity(0.6))
                    
                    TextField("Enter description", text: $description)
                        .textFieldStyle(.roundedBorder)
                        .font(.body)
                        .accessibilityLabel("Trueque description")
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("Tokens")
                        .font(.caption)
                        .foregroundColor(.oceanBase.opacity(0.6))
                    
                    TextField("Amount", text: $tokens)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.body)
                        .accessibilityLabel("Token amount")
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("New Trueque")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let tokenValue = Int(tokens),
                           !title.isEmpty,
                           !description.isEmpty {
                            
                            store.addTrueque(
                                title: title,
                                description: description,
                                tokens: tokenValue
                            )
                            dismiss()
                        }
                    }
                    .disabled(
                        title.isEmpty ||
                        description.isEmpty ||
                        Int(tokens) == nil
                    )
                }
            }
        }
        .dynamicTypeSize(.xSmall ... .accessibility5)
    }
}
