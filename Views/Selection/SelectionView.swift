//
//  SelectionView.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import SwiftUI

struct SelectionView: View {
    
    @ObservedObject var store: TruequeStore
    
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
    }
}

//////////////////////////////////////////////////////////////
// MARK: - Layout
//////////////////////////////////////////////////////////////

extension SelectionView {
    
    @ViewBuilder
    private var contentLayout: some View {
        
        if sizeClass == .regular {
            ipadLayout
        } else {
            iphoneLayout
        }
    }
    
    //////////////////////////////////////////////////////////
    // iPad Layout
    //////////////////////////////////////////////////////////
    
    private var ipadLayout: some View {
        
        HStack(spacing: 80) {
            
            Spacer()
            
            VStack(spacing: 30) {
                
                Text("TRUEQUE TIDE")
                    .font(.system(size: 26, weight: .medium))
                    .tracking(8)
                    .foregroundColor(.oceanBase)
                
                actionColumn
            }
            
            Spacer()
        }
        .frame(maxWidth: 900)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    //////////////////////////////////////////////////////////
    // iPhone Layout
    //////////////////////////////////////////////////////////
    
    private var iphoneLayout: some View {
        
        VStack(spacing: 60) {
            
            Spacer()
            
            Text("TRUEQUE TIDE")
                .font(.system(size: 22, weight: .medium))
                .tracking(6)
                .foregroundColor(.oceanBase)
            
            actionColumn
            
            Spacer()
        }
        .padding()
    }
    
    //////////////////////////////////////////////////////////
    // Shared Column
    //////////////////////////////////////////////////////////
    
    private var actionColumn: some View {
        
        VStack(spacing: 50) {
            
            // COMMUNITY
            VStack(spacing: 10) {
                
                Button {
                    showCommunities = true
                } label: {
                    Text("🌐")
                        .font(.system(size: store.selectedCommunity == nil ? 90 : 60))
                        .animation(.easeInOut(duration: 0.3), value: store.selectedCommunity != nil)
                }
                
                Text("Community")
                    .font(.caption)
                    .foregroundColor(.oceanBase)
            }
            
            // USER
            VStack(spacing: 10) {
                
                Button {
                    if store.selectedCommunity != nil {
                        showUsers = true
                    }
                } label: {
                    Text("👤")
                        .font(.system(size: store.selectedCommunity != nil && store.selectedUser == nil ? 90 : 60))
                        .foregroundColor(
                            store.selectedCommunity == nil ?
                            .gray.opacity(0.4) :
                            .oceanAccent
                        )
                        .animation(.easeInOut(duration: 0.3), value: store.selectedUser != nil)
                }
                
                Text("User")
                    .font(.caption)
                    .foregroundColor(.oceanBase)
            }
        }
    }
}


// MARK: - Adaptive Modals (Centered Sheet)


struct SelectionModals: ViewModifier {
    
    var store: TruequeStore
    
    @Binding var showCommunities: Bool
    @Binding var showUsers: Bool
    
    var isIPad: Bool
    
    func body(content: Content) -> some View {
        
        content
        
        ////////////////////////////////////////////////////////
        // COMMUNITY
        ////////////////////////////////////////////////////////
        
        .sheet(isPresented: $showCommunities) {
            modalContainer {
                communityList
            }
        }
        
        ////////////////////////////////////////////////////////
        // USER
        ////////////////////////////////////////////////////////
        
        .sheet(isPresented: $showUsers) {
            modalContainer {
                userList
            }
        }
    }
    
    //////////////////////////////////////////////////////////
    // Modal Container
    //////////////////////////////////////////////////////////
    
    private func modalContainer<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        
        Group {
            if isIPad {
                // iPad centrado tipo card
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15), radius: 25)
                    
                    content()
                        .padding()
                }
                .frame(width: 420, height: 520)
            } else {
                // iPhone normal
                NavigationView {
                    content()
                }
            }
        }
    }
    
    //////////////////////////////////////////////////////////
    // Lists
    //////////////////////////////////////////////////////////
    
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
//////////////////////////////////////////////////////////////
// MARK: - Conditional Modifier Helper
//////////////////////////////////////////////////////////////

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
