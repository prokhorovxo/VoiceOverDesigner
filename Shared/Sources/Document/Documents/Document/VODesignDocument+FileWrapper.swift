import Foundation

extension VODesignDocumentProtocol {
    
    // MARK: - Write
    func fileWrapper() throws -> FileWrapper {
        
        // Just invalidate controls every time to avoid lose of user's data
        invalidateWrapperIfPossible(fileInFrame: FileName.controls)
        frameWrapper.addFileWrapper(try controlsWrapper())
        
        // Preview depends on elements and should be invalidated
        invalidateWrapperIfPossible(fileInRoot: FolderName.quickLook)
        if let previewWrapper = previewWrapper() {
            documentWrapper.addFileWrapper(previewWrapper)
        }
        
        if frameWrapper.fileWrappers?[FileName.screen] == nil,
           let imageWrapper = imageWrapper() {
            frameWrapper.addFileWrapper(imageWrapper)
        }
        
        if frameWrapper.fileWrappers?[FileName.info] == nil {
            let frameMetaWrapper = infoWrapper()
            frameWrapper.addFileWrapper(frameMetaWrapper)
        }
    
        return documentWrapper
    }
}

extension VODesignDocumentProtocol {
    
    var isBetaStructure: Bool {
        frameWrapper.filename == documentWrapper.filename
    }
    
    var frameWrapper: FileWrapper {
        (documentWrapper.fileWrappers?[defaultFrameName] ?? documentWrapper)
    }
    
    private func controlsWrapper() throws -> FileWrapper {
        let codingService = AccessibilityViewCodingService()
        let wrapper = FileWrapper(regularFileWithContents: try codingService.data(from: controls))
        wrapper.preferredFilename = FileName.controls
        return wrapper
    }
    
    private func imageWrapper() -> FileWrapper? {
        guard let image = image,
              let imageData = image.png()
        else { return nil }
        
        let imageWrapper = FileWrapper(regularFileWithContents: imageData)
        imageWrapper.preferredFilename = FileName.screen
        
        
        return imageWrapper
    }
    
    private func previewWrapper() -> FileWrapper? {
        guard let image = previewSource?.previewImage() ?? image,
              let imageData = image.heic(compressionQuality: 0.51)
        else { return nil }
        
        let imageWrapper = FileWrapper(regularFileWithContents: imageData)
        imageWrapper.preferredFilename = FileName.quickLookFile
        
        let quicklookFolder = FileWrapper(directoryWithFileWrappers: [FolderName.quickLook: imageWrapper])
        quicklookFolder.preferredFilename = FolderName.quickLook
        return quicklookFolder
    }
    
    private func infoWrapper() -> FileWrapper {
        let frameMetaData = try! FrameInfoPersistance.data(frame: frameInfo)
        
        let frameMetaWrapper = FileWrapper(regularFileWithContents: frameMetaData)
        frameMetaWrapper.preferredFilename = FileName.info
        return frameMetaWrapper
    }
}

// MARK: - Read
extension VODesignDocumentProtocol {
    
    func read(
        from packageWrapper: FileWrapper
    ) throws {
        guard packageWrapper.isDirectory else {
            recreateDocumentWrapper()
            print("Nothing to read, probably the document was just created")
            return
        }
        
        // Keep referente to gently update files for iCloud
        self.documentWrapper = packageWrapper
        let frameFolder = frameWrapper.fileWrappers!

        if
            let controlsWrapper = frameFolder[FileName.controls],
            let controlsData = controlsWrapper.regularFileContents
        {
            let codingService = AccessibilityViewCodingService()
            controls = try codingService.controls(from: controlsData)
        }

        if let imageWrapper = frameFolder[FileName.screen],
           let imageData = imageWrapper.regularFileContents {
            image = Image(data: imageData)
        }

        if let frameInfoWrapper = frameFolder[FileName.info],
           let infoData = frameInfoWrapper.regularFileContents,
            let info = try? JSONDecoder().decode(FrameInfo.self,
                                                 from: infoData) {
            frameInfo = info
        }
        
        if isBetaStructure {
            // Reset document wrapper to update file structure
            recreateDocumentWrapper()
        }
    }
    
    private func recreateDocumentWrapper() {
        self.documentWrapper = FileWrapper(directoryWithFileWrappers: [:])
        let frameWrapper = FileWrapper(directoryWithFileWrappers: [:])
        frameWrapper.preferredFilename = defaultFrameName
        self.documentWrapper.addFileWrapper(frameWrapper)
    }
    
    func invalidateWrapperIfPossible(fileInFrame: String) {
        if let imageWrapper = frameWrapper.fileWrappers?[fileInFrame] {
            frameWrapper.removeFileWrapper(imageWrapper)
        }
    }
    
    func invalidateWrapperIfPossible(fileInRoot: String) {
        if let wrapper = documentWrapper.fileWrappers?[fileInRoot] {
            documentWrapper.removeFileWrapper(wrapper)
        }
    }
}
