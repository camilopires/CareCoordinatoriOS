// CareCoordinator/Utilities/ErrorView.swift
import SwiftUI

struct ErrorBanner: View {
    let message: String
    let onDismiss: (() -> Void)?

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.yellow)
            Text(message)
                .font(.subheadline)
            Spacer()
            if let onDismiss {
                Button { onDismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
    }
}

struct RetryView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Something went wrong", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") { onRetry() }
                .buttonStyle(.borderedProminent)
        }
    }
}
