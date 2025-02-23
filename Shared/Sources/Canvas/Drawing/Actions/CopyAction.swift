import CoreGraphics

public class CopyAction: MoveAction, DraggingAction {
    public func cancel() {
        control.updateWithoutAnimation {
            control.frame = initialFrame
        }
    }
    
    
    public func end(at coordinate: CGPoint) -> DraggingAction? {
        return self
    }
}
