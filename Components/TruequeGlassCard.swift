//
//  TruequeGlassCard.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import SwiftUI

struct TruequeGlassCard: View {

    var title: String
    var owner: String
    var description: String
    var tokens: Double

    var body: some View {

        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.oceanBase)

                Spacer()

                Text("\(Int(tokens)) TT")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.oceanAccent)
            }

            Text(owner)
                .font(.caption)
                .foregroundColor(.oceanBase.opacity(0.6))

            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.oceanBase.opacity(0.75))
        }
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(Color.glassBorder, lineWidth: 1)
        )
    }
}
