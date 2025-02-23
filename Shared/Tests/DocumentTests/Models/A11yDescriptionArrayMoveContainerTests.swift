import Document
import XCTest
import CustomDump

class A11yDescriptionArrayMoveContainerTests: A11yDescriptionArrayTests {
    
    func test_simpleMove() {
        sut.move(el1, fromContainer: nil, toIndex: 2, toContainer: nil)
        sut.assert(labels: "2", "1", "3")
    }
    
    // MARK: - Inside containers
    
    func test_correctDescription() {
        sut.wrapInContainer([el1], label: "Container1")
        sut.assert(labels: "Container1: 1", "2", "3")
    }
    
    func test_whenMove2IntoContainer_shouldMoveToContainer() {
        let container = sut.wrapInContainer([el1], label: "Container1")
        
        sut.move(el2, fromContainer: nil,
                 toIndex: 1, toContainer: container!)
        
        sut.assert(labels: "Container1: 1, 2", "3")
    }
    
    // MARK: Outside containers
    
    func test_whenMove1OutOfContainer_shouldKeepContainerEmpty() {
        let container = sut.wrapInContainer([el1], label: "Container")
        
        sut.move(el1, fromContainer: container,
                 toIndex: 1, toContainer: nil)
        
        sut.assert(labels: "Container", "1", "2", "3")
    }
    
    func test_whenMoveInSameContainer() {
        let container = sut.wrapInContainer([el1, el2], label: "Container")
        
        sut.move(el1, fromContainer: container,
                 toIndex: 2, toContainer: container)
        
        sut.assert(labels: "Container: 2, 1", "3")
    }
    
    func test_whenMoveInSameContainerToBeginning() {
        let container = sut.wrapInContainer([el1, el2], label: "Container")
        sut.assert(labels: "Container: 1, 2", "3")
        
        sut.move(el2, fromContainer: container,
                 toIndex: 0, toContainer: container)
        
        sut.assert(labels: "Container: 2, 1", "3")
    }
    
    func test_whenMoveFromOneContainerToAnother() {
        let container1 = sut.wrapInContainer([el1], label: "Container1")
        let container2 = sut.wrapInContainer([el2], label: "Container2")
        
        sut.move(el1, fromContainer: container1,
                 toIndex: 0, toContainer: container2)
        
        sut.assert(labels: "Container1", "Container2: 1, 2", "3")
    }
}
