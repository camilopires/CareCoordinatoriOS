// CareCoordinator/Views/PTO/PTORequestView.swift
import SwiftUI

struct PTORequestView: View {
    @Bindable var viewModel: PTOViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Dates") {
                DatePicker(
                    "Start Date",
                    selection: $viewModel.startDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                DatePicker(
                    "End Date",
                    selection: $viewModel.endDate,
                    in: viewModel.startDate...,
                    displayedComponents: .date
                )
            }

            Section("Reason (Optional)") {
                TextField("Why do you need time off?", text: $viewModel.reason, axis: .vertical)
                    .lineLimit(3...6)
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button("Submit Request") {
                    Task {
                        await viewModel.submitPTORequest()
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .navigationTitle("Request Time Off")
    }
}
