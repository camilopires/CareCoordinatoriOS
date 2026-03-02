// CareCoordinator/Views/Onboarding/OnboardingView.swift
import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool

    @State private var currentPage = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "heart.circle.fill",
            title: "Welcome to CareCoordinator",
            description: "The privacy-first app for managing home care with rotating carers.",
            color: .blue
        ),
        OnboardingPage(
            icon: "calendar.badge.clock",
            title: "Smart Scheduling",
            description: "Auto-rotating shift schedules, PTO management, and availability tracking — all in one place.",
            color: .green
        ),
        OnboardingPage(
            icon: "lock.shield.fill",
            title: "Privacy Built In",
            description: "End-to-end encryption for care plans. Row-level security. Your data stays yours.",
            color: .purple
        ),
        OnboardingPage(
            icon: "brain",
            title: "Meet Care-y",
            description: "Your on-device AI assistant. Ask about schedules, tasks, and care plans — nothing leaves your device.",
            color: .pink
        )
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    VStack(spacing: 24) {
                        Spacer()

                        Image(systemName: pages[index].icon)
                            .font(.system(size: 80))
                            .foregroundStyle(pages[index].color)

                        Text(pages[index].title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text(pages[index].description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button {
                if currentPage < pages.count - 1 {
                    withAnimation { currentPage += 1 }
                } else {
                    hasCompletedOnboarding = true
                }
            } label: {
                Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}
