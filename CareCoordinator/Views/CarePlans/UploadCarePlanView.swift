// CareCoordinator/Views/CarePlans/UploadCarePlanView.swift
import SwiftUI
import UniformTypeIdentifiers

struct UploadCarePlanView: View {
    @Bindable var viewModel: CarePlanViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var selectedPDFData: Data?
    @State private var showingFilePicker = false
    @State private var selectedFileName: String?

    var body: some View {
        Form {
            Section("Plan Details") {
                TextField("Title", text: $title)

                Button {
                    showingFilePicker = true
                } label: {
                    HStack {
                        Image(systemName: selectedPDFData != nil ? "checkmark.circle.fill" : "doc.badge.plus")
                            .foregroundStyle(selectedPDFData != nil ? .green : .blue)
                        Text(selectedFileName ?? "Choose PDF File")
                    }
                }
            }

            if viewModel.isUploading {
                Section {
                    HStack {
                        ProgressView()
                        Text("Encrypting and uploading...")
                            .padding(.leading, 8)
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
        .navigationTitle("Upload Care Plan")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Upload") {
                    guard let data = selectedPDFData else { return }
                    Task {
                        await viewModel.uploadPDF(title: title, data: data)
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                }
                .disabled(title.isEmpty || selectedPDFData == nil || viewModel.isUploading)
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [UTType.pdf]
        ) { result in
            switch result {
            case .success(let url):
                guard url.startAccessingSecurityScopedResource() else { return }
                defer { url.stopAccessingSecurityScopedResource() }
                selectedPDFData = try? Data(contentsOf: url)
                selectedFileName = url.lastPathComponent
            case .failure:
                viewModel.errorMessage = "Failed to read file"
            }
        }
    }
}
