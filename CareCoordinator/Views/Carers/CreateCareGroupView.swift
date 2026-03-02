// CareCoordinator/Views/Carers/CreateCareGroupView.swift
import SwiftUI

struct CreateCareGroupView: View {
    @Environment(CareGroupViewModel.self) private var careGroupVM
    @State private var name = ""
    @State private var privacyMode: PrivacyMode = .full
    @State private var shiftStart = Calendar.current.date(from: DateComponents(hour: 8)) ?? Date()
    @State private var shiftEnd = Calendar.current.date(from: DateComponents(hour: 20)) ?? Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Care Group Name") {
                    TextField("e.g., Dad's Care Team", text: $name)
                }

                Section {
                    Picker("Privacy Mode", selection: $privacyMode) {
                        ForEach(PrivacyMode.allCases, id: \.self) { mode in
                            VStack(alignment: .leading) {
                                Text(mode.rawValue.capitalized)
                            }
                            .tag(mode)
                        }
                    }
                } header: {
                    Text("Privacy")
                } footer: {
                    Text(privacyDescription)
                }

                Section("Default Shift Times") {
                    DatePicker("Start", selection: $shiftStart, displayedComponents: .hourAndMinute)
                    DatePicker("End", selection: $shiftEnd, displayedComponents: .hourAndMinute)
                }

                if let error = careGroupVM.errorMessage {
                    Section { Text(error).foregroundStyle(.red) }
                }

                Section {
                    Button {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm"
                        Task {
                            await careGroupVM.createCareGroup(
                                name: name,
                                privacyMode: privacyMode,
                                shiftStart: formatter.string(from: shiftStart),
                                shiftEnd: formatter.string(from: shiftEnd)
                            )
                        }
                    } label: {
                        if careGroupVM.isLoading {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text("Create Care Group").frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(name.isEmpty || careGroupVM.isLoading)
                }
            }
            .navigationTitle("New Care Group")
        }
    }

    private var privacyDescription: String {
        switch privacyMode {
        case .full: "Carers see only their own shifts and data. Maximum privacy."
        case .anonymous: "Carers see all shifts but carer names are hidden."
        case .open: "Carers see everything including each other's names."
        }
    }
}
