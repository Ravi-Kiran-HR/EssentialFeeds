//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedsTests
//
//  Created by Ravi Kiran HR on 15/02/22.
//

import XCTest
@testable import EssentialFeeds

class RemoteFeedLoaderTests: XCTestCase {
    
    var sut: RemoteFeedLoader? = nil
    // Put setup code here. This method is called before the invocation of each test method in the class.
    override func setUpWithError() throws {
    }
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    override func tearDownWithError() throws {
        
    }
    
    func test_load_ReturnsData() {
        let url = URL(string: "https://www.someOtherUrl.com")!
        let client = HTTPClientMock()
        sut = RemoteFeedLoader(url, client)
        sut?.load()
        XCTAssertNotNil(client.requestedUrl)
    }
    
}

class HTTPClientMock :HTTPClient {
    var requestedUrl: URL?
    func get(from url: URL) {
        requestedUrl = url
    }
    
    
}
