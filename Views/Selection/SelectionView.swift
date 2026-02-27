//
//  SelectionView.swift
//  TruequeTide
//
//  Created by Guillermo Lira on 17/02/26.
//


import SwiftUI
import Combine

struct SelectionView: View {

    @ObservedObject var store: TruequeStore
    @EnvironmentObject var accessibility: AccessibilityManager
    @Environment(\.horizontalSizeClass) private var sizeClass

    // Coordinator hooks (RootView)
    var onBack: () -> Void
    var onReady: () -> Void

    @State private var showCommunities = false
    @State private var showUsers = false

    // Evita llamar onReady múltiples veces
    @State private var didAutoAdvance = false

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
        .onAppear {
            // Si regresas a Selection, permite auto-advance otra vez si vuelven a elegir.
            didAutoAdvance = false
        }
        // ✅ NO usa onChange (Community/User no son Equatable)
        .onReceive(store.$selectedCommunity) { _ in
            checkIfReady()
        }
        .onReceive(store.$selectedUser) { _ in
            checkIfReady()
        }
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

            VStack(spacing: 26) {

                topBar

                VStack(spacing: 26) {

                    Text("TRUEQUE TIDE")
                        .font(.title2)
                        .fontWeight(.medium)
                        .tracking(6)
                        .foregroundColor(.oceanBase)

                    Text("Choose a community, then a profile.")
                        .font(.caption)
                        .foregroundColor(.oceanBase.opacity(0.65))

                    actionColumn
                }
                .padding(.top, 10)

                Spacer()
            }

            Spacer()
        }
        .frame(maxWidth: 900)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var iphoneLayout: some View {

        VStack(spacing: 28) {

            topBar

            Spacer()

            Text("TRUEQUE TIDE")
                .font(.title3)
                .fontWeight(.medium)
                .tracking(5)
                .foregroundColor(.oceanBase)

            Text("Choose a community, then a profile.")
                .font(.caption)
                .foregroundColor(.oceanBase.opacity(0.65))

            actionColumn

            Spacer()
        }
        .padding()
    }

    private var topBar: some View {

        HStack {

            Button {
                onBack()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.oceanBase.opacity(0.85))
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.glassBorder, lineWidth: 1)
                    )
            }
            .accessibilityLabel("Back")
            .accessibilityHint("Returns to the previous screen.")

            Spacer()

            // Indicador ligero de estado
            HStack(spacing: 8) {

                statusPill(
                    title: store.selectedCommunity == nil ? "Community: Not set" : "Community: Set",
                    isOn: store.selectedCommunity != nil
                )

                statusPill(
                    title: store.selectedUser == nil ? "User: Not set" : "User: Set",
                    isOn: store.selectedUser != nil
                )
            }
            .accessibilityHidden(true)
        }
        .padding(.top, sizeClass == .regular ? 6 : 2)
    }

    private func statusPill(title: String, isOn: Bool) -> some View {

        Text(title)
            .font(.caption2)
            .foregroundColor(isOn ? .oceanAccent : .oceanBase.opacity(0.55))
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isOn ? Color.oceanAccent.opacity(0.35) : Color.glassBorder, lineWidth: 1)
            )
    }

    private var actionColumn: some View {

        VStack(spacing: 44) {

            VStack(spacing: 10) {

                Button {
                    showCommunities = true
                } label: {
                    Text("🌐")
                        .font(
                            store.selectedCommunity == nil
                            ? .system(size: accessibility.reduceMotionMode ? 70 : 80)
                            : .system(size: 55)
                        )
                }
                .animation(
                    accessibility.reduceMotionMode ? nil : .easeInOut(duration: 0.3),
                    value: store.selectedCommunity != nil
                )
                .accessibilityLabel("Select community")
                .accessibilityHint("Opens the list of communities.")

                Text("Community")
                    .font(.caption)
                    .foregroundColor(.oceanBase)
            }

            VStack(spacing: 10) {

                Button {
                    if store.selectedCommunity != nil {
                        showUsers = true
                    } else {
                        softAnnounce("Select a community first.")
                    }
                } label: {
                    Text("👤")
                        .font(
                            store.selectedCommunity != nil && store.selectedUser == nil
                            ? .system(size: accessibility.reduceMotionMode ? 70 : 80)
                            : .system(size: 55)
                        )
                        .foregroundColor(
                            store.selectedCommunity == nil
                            ? .gray.opacity(0.4)
                            : .oceanAccent
                        )
                }
                .animation(
                    accessibility.reduceMotionMode ? nil : .easeInOut(duration: 0.3),
                    value: store.selectedUser != nil
                )
                .accessibilityLabel("Select user")
                .accessibilityHint("Opens the list of users for the selected community.")

                Text("User")
                    .font(.caption)
                    .foregroundColor(.oceanBase)
            }
        }
    }

    private func checkIfReady() {

        guard store.selectedCommunity != nil,
              store.selectedUser != nil else { return }

        guard !didAutoAdvance else { return }
        didAutoAdvance = true

        // Un toque haptics leve (si está permitido)
        if accessibility.animationsEnabled {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }

        onReady()
    }

    private func softAnnounce(_ message: String) {
        guard UIAccessibility.isVoiceOverRunning else { return }
        UIAccessibility.post(notification: .announcement, argument: message)
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
        .navigationTitle("Communities")
    }

    private var userList: some View {

        List(store.selectedCommunity?.users ?? []) { user in
            Button(user.name) {
                store.selectUser(user)
                showUsers = false
            }
        }
        .navigationTitle("Users")
    }
}
