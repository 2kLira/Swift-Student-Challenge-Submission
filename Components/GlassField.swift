//
//  GlassField.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import SwiftUI

struct GlassField: View {

    var title: String
    @Binding var text: String

    var body: some View {

        VStack(alignment: .leading, spacing: 6) {

            Text(title)
                .font(.caption)
                .foregroundColor(.oceanAccent)

            TextField("", text: $text)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.glassBorder, lineWidth: 1)
                )
        }
    }
}
