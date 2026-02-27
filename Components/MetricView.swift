//
//  MetricView.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import SwiftUI

struct MetricView: View {
    
    var title: String
    var value: Int
    
    var body: some View {
        
        VStack {
            
            Text("\(value)")
                .font(.system(size: 48, weight: .thin))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
