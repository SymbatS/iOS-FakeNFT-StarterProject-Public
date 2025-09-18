import XCTest

final class CatalogUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITestMode"]
        app.launch()
    }
    
    func testCatalogShowsCollections() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Каталог"].tap()

        let table = app.tables["CatalogTable"]
        XCTAssertTrue(table.waitForExistence(timeout: 10), "Таблица каталога не появилась")
    }


    func testTapCollectionOpensNFTScreen() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Каталог"].tap()

        let table = app.tables["CatalogTable"]
        XCTAssertTrue(table.waitForExistence(timeout: 10))

        let firstCell = table.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))
        firstCell.tap()

        let nftCollection = app.collectionViews["NFTCollectionView"]
        XCTAssertTrue(nftCollection.waitForExistence(timeout: 10), "Экран NFT не открылся")
    }
}
