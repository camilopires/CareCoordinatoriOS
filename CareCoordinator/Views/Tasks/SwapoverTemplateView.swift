// CareCoordinator/Views/Tasks/SwapoverTemplateView.swift
import SwiftUI

struct SwapoverTemplateView: View {
    @State var viewModel = TaskViewModel()
    @State private var newItemTitle = ""
    let careGroupId: UUID

    var body: some View {
        List {
            Section("Checklist Items") {
                ForEach(viewModel.swapoverTemplate) { item in
                    HStack {
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.secondary)
                        Text(item.title)
                    }
                }
                .onDelete { indices in
                    for index in indices {
                        let item = viewModel.swapoverTemplate[index]
                        Task { await viewModel.deleteTemplateItem(item) }
                    }
                }
            }

            Section("Add Item") {
                HStack {
                    TextField("Checklist item", text: $newItemTitle)
                    Button("Add") {
                        guard !newItemTitle.isEmpty else { return }
                        Task {
                            await viewModel.addTemplateItem(title: newItemTitle, description: nil)
                            newItemTitle = ""
                        }
                    }
                    .disabled(newItemTitle.isEmpty)
                }
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error).foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Swapover Checklist")
        .task {
            viewModel.careGroupId = careGroupId
            await viewModel.loadSwapoverTemplate()
        }
    }
}
