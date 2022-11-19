import UIKit
import Document
import Canvas
import Combine

import SwiftUI
import SettingsSwiftUI

public class PreviewMainViewController: UIViewController {
    private var presenter: CanvasPresenter!
    
    private var document: VODesignDocument!
    public init(document: VODesignDocument) {
        self.document = document
        self.presenter = CanvasPresenter(document: document)
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAndDraw()
        addDocumentStateObserving()
    }
    
    private var cancellables = Set<AnyCancellable>()
    private func loadAndDraw() {
        document.open { isSuccess in
            if isSuccess {
                self.embedCanvas()
                self.presenter.selectedPublisher.sink { description in
                    guard let description = description else { return }
                    
                    let details = UIHostingController(rootView: SettingsView())
                    self.present(details, animated: true)
                    
                    // TODO: Deselect on dismiss
                }.store(in: &self.cancellables)
            } else {
                fatalError() // TODO: Present something to user
            }
        }
    }
    
    private func embedCanvas() {
        let canvas = VODesignPreviewViewController.controller(presenter: presenter)
        
        addChild(canvas)
        view.addSubview(canvas.view)
        canvas.view.frame = view.frame // TODO: Constraints
        canvas.didMove(toParent: self)
        
        embedFullFrame(canvas)
    }
}

// MARK: - iCloud sync
extension PreviewMainViewController {
    private func addDocumentStateObserving() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(Self.documentStateChanged(_:)),
            name: UIDocument.stateChangedNotification, object: document)
    }
    
    @objc
    private func documentStateChanged(_ notification: Notification) {
        document.printState()
        
        if document.documentState == .progressAvailable {
            loadAndDraw()
        }
    }
}

public extension UIViewController {
    func embedFullFrame(_ viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        
        if let subiew = viewController.view {
            subiew.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                subiew.leftAnchor.constraint(equalTo: view.leftAnchor),
                subiew.rightAnchor.constraint(equalTo: view.rightAnchor),
                subiew.topAnchor.constraint(equalTo: view.topAnchor),
                subiew.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }
}
