//
//  SelectionView.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import SwiftUI

struct SelectionView: View {
    
    @ObservedObject var store: TruequeStore
    @EnvironmentObject var accessibility: AccessibilityManager
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    @State private var showCommunities = false
    @State private var showUsers = false
    
    var body: some View {
        
        ZStack {
            
            LinearGradient(
                colors: [
                    Color.backgroundSand,
                    Color.white.opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            contentLayout
        }
        .modifier(SelectionModals(
            store: store,
            showCommunities: $showCommunities,
            showUsers: $showUsers,
            isIPad: sizeClass == .regular
        ))
        .dynamicTypeSize(.xSmall ... .accessibility5)
    }
}

extension SelectionView {
    
    @ViewBuilder
    private var contentLayout: some View {
        if sizeClass == .regular {
            ipadLayout
        } else {
            iphoneLayout
        }
    }
    
    private var ipadLayout: some View {
        
        HStack(spacing: 80) {
            
            Spacer()
            
            VStack(spacing: 30) {
                
                Text("TRUEQUE TIDE")
                    .font(.title2)
                    .fontWeight(.medium)
                    .tracking(6)
                    .foregroundColor(.oceanBase)
                
                actionColumn
            }
            
            Spacer()
        }
        .frame(maxWidth: 900)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var iphoneLayout: some View {
        
        VStack(spacing: 60) {
            
            Spacer()
            
            Text("TRUEQUE TIDE")
                .font(.title3)
                .fontWeight(.medium)
                .tracking(5)
                .foregroundColor(.oceanBase)
            
            actionColumn
            
            Spacer()
        }
        .padding()
    }
    
    private var actionColumn: some View {
        
        VStack(spacing: 50) {
            
            VStack(spacing: 10) {
                
                Button {
                    showCommunities = true
                } label: {
                    Text("🌐")
                        .font(
                            store.selectedCommunity == nil ?
                            .system(size: accessibility.reduceMotionMode ? 70 : 80) :
                            .system(size: 55)
                        )
                }
                .animation(
                    accessibility.reduceMotionMode ? nil :
                        .easeInOut(duration: 0.3),
                    value: store.selectedCommunity != nil
                )
                .accessibilityLabel("Select community")
                
                Text("Community")
                    .font(.caption)
                    .foregroundColor(.oceanBase)
            }
            
            VStack(spacing: 10) {
                
                Button {
                    if store.selectedCommunity != nil {
                        showUsers = true
                    }
                } label: {
                    Text("👤")
                        .font(
                            store.selectedCommunity != nil &&
                            store.selectedUser == nil ?
                            .system(size: accessibility.reduceMotionMode ? 70 : 80) :
                            .system(size: 55)
                        )
                        .foregroundColor(
                            store.selectedCommunity == nil ?
                            .gray.opacity(0.4) :
                            .oceanAccent
                        )
                }
                .animation(
                    accessibility.reduceMotionMode ? nil :
                        .easeInOut(duration: 0.3),
                    value: store.selectedUser != nil
                )
                .accessibilityLabel("Select user")
                
                Text("User")
                    .font(.caption)
                    .foregroundColor(.oceanBase)
            }
        }
    }
}

struct SelectionModals: ViewModifier {
    
    var store: TruequeStore
    
    @Binding var showCommunities: Bool
    @Binding var showUsers: Bool
    
    var isIPad: Bool
    
    func body(content: Content) -> some View {
        
        content
        
        .sheet(isPresented: $showCommunities) {
            modalContainer {
                communityList
            }
        }
        
        .sheet(isPresented: $showUsers) {
            modalContainer {
                userList
            }
        }
    }
    
    private func modalContainer<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        
        Group {
            if isIPad {
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15), radius: 25)
                    
                    content()
                        .padding()
                }
                .frame(width: 420, height: 520)
            } else {
                NavigationView {
                    content()
                }
            }
        }
        .dynamicTypeSize(.xSmall ... .accessibility5)
    }
    
    private var communityList: some View {
        List(store.communities) { community in
            Button(community.name) {
                store.selectCommunity(community)
                showCommunities = false
            }
        }
    }
    
    private var userList: some View {
        List(store.selectedCommunity?.users ?? []) { user in
            Button(user.name) {
                store.selectUser(user)
                showUsers = false
            }
        }
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool,
                             transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
