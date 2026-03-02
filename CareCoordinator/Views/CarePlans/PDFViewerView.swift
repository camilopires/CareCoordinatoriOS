// CareCoordinator/Views/CarePlans/PDFViewerView.swift
import PDFKit
import SwiftUI

struct PDFViewerView: UIViewRepresentable {
    let pdfData: Data

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        if let document = PDFDocument(data: pdfData) {
            pdfView.document = document
        }
    }
}
