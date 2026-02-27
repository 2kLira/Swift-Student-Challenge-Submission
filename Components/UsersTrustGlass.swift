//
//  UsersTrustGlass.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import SwiftUI

struct UsersTrustGlass: View {

    @ObservedObject var engine: SimulationEngine

    var body: some View {

        VStack(alignment: .leading, spacing: 14) {

            Text("Community Trust")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.oceanBase.opacity(0.75))
                .padding(.horizontal)

            ForEach(engine.users) { u in
                HStack(spacing: 14) {
                    Text("👤")
                        .font(.system(size: 22))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(u.name)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.oceanBase)

                        Text("Completed: \(u.completed)  •  Balance: \(Int(u.balance)) TT")
                            .font(.caption)
                            .foregroundColor(.oceanBase.opacity(0.6))
                    }

                    Spacer()

                    Text("\(Int(u.trust * 100))%")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.oceanAccent)
                }
                .padding(16)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.glassBorder, lineWidth: 1)
                )
                .padding(.horizontal)
            }
        }
        .padding(.top, 10)
    }
}
