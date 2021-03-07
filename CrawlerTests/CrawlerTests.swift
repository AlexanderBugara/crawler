import XCTest
@testable import Crawler

class CrawlerTests: XCTestCase {
    let str = "Hello, playground, Hello, playground, Hello, playground, Hello, playground, Hello, playground"

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testExample() throws {
        let count = str.count(occurrencesOf: "hello", options: .caseInsensitive)
        XCTAssertEqual(count, 5)
    }

    func testPerformanceExample() throws {
        self.measure {
        }
    }

}
