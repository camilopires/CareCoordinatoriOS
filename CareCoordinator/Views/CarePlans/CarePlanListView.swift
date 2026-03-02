// CareCoordinator/Views/CarePlans/CarePlanListView.swift
import SwiftUI

struct CarePlanListView: View {
    @State private var viewModel = CarePlanViewModel()
    let careGroupId: UUID
    let currentUserId: UUID
    let isClient: Bool

    var body: some View {
        List {
            if viewModel.isLoading && viewModel.carePlans.isEmpty {
                ProgressView("Loading care plans...")
            }

            ForEach(viewModel.carePlans) { plan in
                Button {
                    Task { await viewModel.openCarePlan(plan) }
                } label: {
                    HStack {
                        Image(systemName: "doc.fill")
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading) {
                            Text(plan.title)
                                .font(.headline)
                            Text(plan.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
                .swipeActions(edge: .trailing) {
                    if isClient {
                        Button(role: .destructive) {
                            Task { await viewModel.deleteCarePlan(plan) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Care Plans")
        .toolbar {
            if isClient {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: UploadCarePlanView(viewModel: viewModel)) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(item: Binding(
            get: { viewModel.decryptedPDFData.map { PDFDataWrapper(data: $0) } },
            set: { _ in viewModel.decryptedPDFData = nil }
        )) { wrapper in
            NavigationStack {
                PDFViewerView(pdfData: wrapper.data)
                    .navigationTitle("Care Plan")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") { viewModel.decryptedPDFData = nil }
                        }
                    }
            }
        }
        .task {
            viewModel.careGroupId = careGroupId
            viewModel.currentUserId = currentUserId
            await viewModel.loadCarePlans()
        }
    }
}

// MARK: - Helpers

struct PDFDataWrapper: Identifiable {
    let id = UUID()
    let data: Data
}
