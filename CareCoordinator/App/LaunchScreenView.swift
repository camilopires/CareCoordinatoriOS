// CareCoordinator/App/LaunchScreenView.swift
import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)

                Text("CareCoordinator")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Privacy-first care management")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear { isAnimating = true }
    }
}
