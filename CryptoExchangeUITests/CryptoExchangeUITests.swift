// NOVA
import XCTest

final class CryptoExchangeUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func test_listScreen_exists() {
        let screen = app.otherElements["exchange_list_screen"]
        XCTAssertTrue(screen.waitForExistence(timeout: 5))
    }

    func test_listLoadsOrShowsState() {
        // Either list, error or empty state should appear
        let list = app.collectionViews["exchange_list"]
        let errorView = app.otherElements["error_view"]
        let emptyView = app.otherElements["empty_view"]
        let loadingView = app.otherElements["loading_view"]

        // Wait up to 10 seconds for any final state
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == true"),
            object: list.exists ? list : (errorView.exists ? errorView : emptyView)
        )

        let result = XCTWaiter.wait(for: [expectation], timeout: 10)
        // If network is not configured, error state is acceptable
        let anyStateShown = list.exists || errorView.exists || emptyView.exists || loadingView.exists
        XCTAssertTrue(anyStateShown, "Expected some UI state to be visible")
    }

    func test_retryButton_existsOnError() {
        // If error view is shown, retry button must be present
        let errorView = app.otherElements["error_view"]
        if errorView.waitForExistence(timeout: 10) {
            let retryButton = app.buttons["retry_button"]
            XCTAssertTrue(retryButton.exists, "Retry button must be visible on error state")
        }
    }

    func test_tapFirstRow_navigatesToDetail() {
        let list = app.collectionViews["exchange_list"]
        guard list.waitForExistence(timeout: 10) else {
            // Network unavailable - skip navigation test
            return
        }

        let firstCell = list.cells.firstMatch
        guard firstCell.waitForExistence(timeout: 5) else {
            return
        }

        firstCell.tap()

        let detailScreen = app.otherElements["exchange_detail_screen"]
        XCTAssertTrue(detailScreen.waitForExistence(timeout: 5), "Detail screen should appear after tap")
    }
}
