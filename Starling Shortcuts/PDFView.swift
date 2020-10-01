//
//  PDFView.swift
//  Starling Shortcuts
//
//  Created by Andrew Glen on 01/10/2020.
//

import Foundation
import PDFKit
import SwiftUI

struct PDFView: UIViewRepresentable {
    typealias UIViewType = PDFKit.PDFView
    
    private var data: Data
    
    init(pdfData: Data) {
        self.data = pdfData
    }
    
    func makeUIView(context: Context) -> UIViewType {
        let view = PDFKit.PDFView(frame: .zero)
        view.document = PDFDocument(data: data)
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
