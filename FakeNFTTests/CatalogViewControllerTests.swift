import XCTest
@testable import FakeNFT

final class CatalogViewControllerTests: XCTestCase {
    
    func makeCategories() -> [FakeNFT.Category] {
        [
            FakeNFT.Category(
                id: "1",
                title: "Art",
                count: 10,
                image: nil,
                description: "Art NFTs",
                author: "Alice",
                authorURL: URL(string: "https://example.com")!
            ),
            FakeNFT.Category(
                id: "2",
                title: "Music",
                count: 5,
                image: nil,
                description: "Music NFTs",
                author: "Bob",
                authorURL: URL(string: "https://example.com")!
            )
        ]
    }
    
    func testSortByNftCount() {
        let categories = makeCategories()
        let mockService = MockCatalogService(mode: .success(categories))
        let sut = CatalogViewController(catalogService: mockService)

        sut.loadViewIfNeeded()

        let exp = expectation(description: "Wait for categories")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let titles = sut.exposedCategories.map { "\($0.title) (\($0.count))" }
            XCTAssertEqual(titles, ["Art (10)", "Music (5)"])
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}
