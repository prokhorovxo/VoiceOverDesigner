#if canImport(XCTest) && canImport(AppKit)

import Foundation
import Document
import XCTest

extension VODesignDocument {
    public static func testDocument(
        name: String,
        saveImmediately: Bool = false,
        testCase: XCTestCase
    ) -> VODesignDocument {
        let document = VODesignDocument(file: testURL(name: name))
        if saveImmediately {
            document.save(testCase: testCase)
        }
        return document
    }
    
    public static func removeTestDocument(name: String) throws {
        try FileManager.default
            .removeItem(at: testURL(name: name))
    }
    
    public static func testURL(name: String) -> URL {
        return Self.path
            .appendingPathComponent("\(name).vodesign",
                                    isDirectory: false)
    }
    
    public static var path: URL {
        FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask).first!
    }
    
    public func save(testCase: XCTestCase) {
        let expectation = testCase.expectation(description: "Save file")
        save(to: fileURL!, ofType: Self.vodesign, for: .saveOperation) { error in
            if let error = error {
                Swift.print("saving error: \(error)")
            } else {
                Swift.print("saved successfully")
            }
            
            // TODO: Handle
            expectation.fulfill()
        }
        
        testCase.wait(for: [expectation], timeout: 1)
    }
    
    public func read() throws {
        try read(from: fileURL!, ofType: Self.vodesign)
    }
}
#endif
