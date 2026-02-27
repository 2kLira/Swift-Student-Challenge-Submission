//
//  OffsetReader.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import SwiftUI

struct OffsetReader: View {
    var onChange: (CGFloat) -> Void

    var body: some View {
        GeometryReader { geo in
            Color.clear
                .onAppear { onChange(geo.frame(in: .global).minY) }
                .onChange(of: geo.frame(in: .global).minY) { v in onChange(v) }
        }
    }
}
