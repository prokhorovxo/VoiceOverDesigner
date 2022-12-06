//
//  CanvasPresenter.swift
//  VoiceOver Designer
//
//  Created by Mikhail Rubanov on 05.05.2022.
//

import Document
import CoreText
import Combine
import TextRecognition

public protocol CanvasPresenterUIProtocol: AnyObject {
    func image(at frame: CGRect) async -> CGImage?
}

public class CanvasPresenter: DocumentPresenter {
   
    public override convenience init(document: VODesignDocumentProtocol) {
        self.init(document: document,
             textRecognition: TextRecognitionService())
    }
    
    init(
        document: VODesignDocumentProtocol,
        textRecognition: TextRecognitionServiceProtocol)
    {
        self.textRecognition = textRecognition
        
        super.init(document: document)
    }
    
    weak var screenUI: CanvasPresenterUIProtocol!
    
    public func didLoad(ui: DrawingView, screenUI: CanvasPresenterUIProtocol) {
        self.ui = ui
        self.screenUI = screenUI
        self.drawingController = DrawingController(view: ui)
        
        draw(controls: document.controls)
        redrawOnControlChanges()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func redrawOnControlChanges() {
        document
            .controlsPublisher
            .sink(receiveValue: redraw(controls:))
            .store(in: &cancellables)
        
        selectedPublisher
            .sink(receiveValue: updateSelectedControl)
            .store(in: &cancellables)
    }
    
    private func redraw(controls: [any AccessibilityView]) {
        drawingController.view.removeAll()
        draw(controls: controls)
        updateSelectedControl(selectedPublisher.value)
    }
    
    public func draw(controls: [any AccessibilityView]) {
        drawingController.drawControls(controls)
    }
    
    // MARK: Mouse
    public func mouseDown(on location: CGPoint) {
        guard document.image != nil else { return }
        drawingController.mouseDown(on: location)
    }
    
    public func mouseDragged(on location: CGPoint) {
        drawingController.drag(to: location)
    }
   
    public func mouseUp(on location: CGPoint) {
        let action = drawingController.end(coordinate: location)
        
        let control = finishAciton(action)
        
        if let control = control {
            recongizeText(under: control)
        }
    }
    
    private func finishAciton(_ action: DraggingAction?) -> A11yControl? {
        switch action {
        case let new as NewControlAction:
            document.undoManager?.registerUndo(withTarget: self, handler: { target in
                target.delete(model: new.control.model!)
            })
           
            append(control: new.control.model!)
            select(control: new.control)
            return new.control
            
        case let translate as TranslateAction:
            document.undoManager?.registerUndo(withTarget: self, handler: { target in
                translate.undo()
            })
            save()
            return translate.control
            
        case let click as ClickAction:
            select(control: click.control)
            return click.control
        case let copy as CopyAction:
            document.undoManager?.registerUndo(withTarget: self, handler: { target in
                target.delete(model: copy.control.model!)
            })
            save()
            return copy.control
        case let resize as ResizeAction:
            document.undoManager?.registerUndo(withTarget: self, handler: { target in
                resize.control.frame = resize.initialFrame
            })
            return resize.control
            // TODO: Register resize as file change
        case .none:
            deselect()
            return nil
            
        default:
            assert(false, "Handle new type here")
            return nil
        }
        
        // TODO: Extract control from action
    }
    
    // MARK: - Selection
    private func updateSelectedControl(_ selectedDescription: (any AccessibilityView)?) {
        guard let selected = selectedDescription else {
            selectedControl = nil
            return
        }
        
        let selectedControl = ui.drawnControls.first(where: { control in
            control.model?.frame == selected.frame
        })
            
        self.selectedControl = selectedControl
    }
    
    public private(set) var selectedControl: A11yControl? {
        didSet {
            oldValue?.isSelected = false
            
            selectedControl?.isSelected = true
        }
    }
    
    public func select(control: A11yControl) {
        selectedPublisher.send(control.model)
    }
    
    func deselect() {
        selectedPublisher.send(nil)
    }
    
    // MARK: - Labels
    public func showLabels() {
        ui.addLabels()
    }
    
    public func hideLabels() {
        ui.removeLabels()
    }
    
    // MARK: - Deletion
    public func delete(model: any AccessibilityView) {
        guard let control = control(for: model) else {
            return
        }
        
        // TODO: Delete control from document.elements
        ui.delete(control: control)
        save()
    }
    
    private func control(for model: any AccessibilityView) -> A11yControl? {
        ui.drawnControls.first { control in
            control.model?.frame == model.frame
        }
    }
    
    // MARK: Text recognition
    
    private let textRecognition: TextRecognitionServiceProtocol
    
    private func recongizeText(under control: A11yControl) {
        Task {
            guard let backImage = await screenUI.image(
                at: control.frame)
            else { return }
            
            await recognizeText(image: backImage, control: control)
        }
    }
    
    func recognizeText(image: CGImage, control: A11yControl) async {
        do {
            let recognitionResults = try await textRecognition.processImage(image: image)
            let results = RecognitionResult(control: control,
                                            text: recognitionResults)
            
            publish(textRecognition: results)
        } catch let error {
            print(error)
        }
    }
}
