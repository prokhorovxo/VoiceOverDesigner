//
//  ProjectCell.swift
//  Projects
//
//  Created by Andrey Plotnikov on 16.07.2022.
//

import Foundation
import AppKit
import Document

class DocumentCellViewItem: NSCollectionViewItem {
    static let identifier = NSUserInterfaceItemIdentifier(rawValue: String(describing: DocumentCellViewItem.self))
    
    let projectCellView = DocumentCellView()
    
    override func loadView() {
        view = projectCellView
    }
    
    func configure(fileName: String) {
        view.setAccessibilityLabel(fileName)
        projectCellView.fileNameTextField.stringValue = fileName
        projectCellView.layoutSubtreeIfNeeded()
    }

    @MainActor
    var image: NSImage? {
        didSet {
            projectCellView.image = image
        }
    }
    
    var expectedImageSize: CGSize {
        CGSize(width: 125,
               height: 280)
    }
}
