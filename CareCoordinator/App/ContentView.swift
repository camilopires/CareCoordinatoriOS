// CareCoordinator/App/ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            switch authViewModel.authState {
            case .loading:
                ProgressView("Loading...")

            case .unauthenticated:
                LoginView()
                    .environment(authViewModel)

            case .authenticated(let profile):
                if let careGroup = authViewModel.careGroup {
                    // Route to role-specific dashboard
                    switch profile.role {
                    case .client:
                        ClientDashboardView(profile: profile, careGroup: careGroup)
                    case .carer:
                        CarerDashboardView(profile: profile, careGroup: careGroup)
                    }
                } else {
                    // No care group yet — show create/join
                    NoCareGroupView(profile: profile, authViewModel: authViewModel)
                }

            case .needsCareGroup(let profile):
                NoCareGroupView(profile: profile, authViewModel: authViewModel)
            }
        }
        .task {
            await authViewModel.checkSession()
        }
    }
}

struct NoCareGroupView: View {
    let profile: Profile
    @Bindable var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "person.3")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)

                Text("Welcome to CareCoordinator")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("You need to create or join a care group to get started.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                if profile.role == .client {
                    NavigationLink("Create Care Group") {
                        CreateCareGroupView()
                    }
                    .buttonStyle(.borderedProminent)
                }

                NavigationLink("Join with Invite Code") {
                    JoinCareGroupView()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
