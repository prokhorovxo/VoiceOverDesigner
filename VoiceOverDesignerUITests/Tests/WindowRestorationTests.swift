import XCTest

class WindowRestorationTests: DesignerTests {
    func test_whenCloseProjectsWindow_shouldRestoreProjects() throws {
        lauchApp()
        XCTAssertTrue(recent.isVisible, "Should show projects navigator on start")
        
        recent.createNewProject()
        project.goBackToProjects()
        closeWindow()

        lauchApp()
        XCTAssertTrue(recent.isVisible, "Should restore projects window when close from projects")
    }
    
    func test_whenCloseProjectWindow_shouldRestoreProject() throws {
        XCTExpectFailure("Not work")
        lauchApp()
        
        recent.createNewProject()
        project.save(name: "Test name")
        // TODO: Save document to have url for them
        closeWindow()

        lauchApp()
        XCTAssertFalse(recent.isVisible, "Should restore new project window when close from open project")
        
        // TODO: Add removing teardown
    }
}
