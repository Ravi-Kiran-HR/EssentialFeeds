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
    var url: URL!
    var client: HTTPClientMock!
    // Put setup code here. This method is called before the invocation of each test method in the class.
    override func setUpWithError() throws {
        sut = getSUT()
    }
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    override func tearDownWithError() throws {
        sut = nil
        url = nil
        client = nil
    }
    
    func test_load_Invoked_with_URL() {
        sut?.load()
        XCTAssertNotNil(client.requestedUrl)
    }
    
    func test_load_Invoked_with_expected_URL() {
        sut?.load()
        XCTAssertEqual(client.requestedUrl, URL(string: "https://www.someOtherUrl.com")!)
    }
    
    func test_load_InvokedTwice_with_expected_2URLs() {
        sut?.load()
        sut?.load()
        XCTAssertEqual(client.invocationCount, 2)
    }
    
    func test_load_Invoked_expecting_error() {
        sut?.load()
        XCTAssertEqual(url, client.requestedUrl)
    }
    
    // SUTFactory
    private func getSUT(_ url1: URL = URL(string: "https://www.someOtherUrl.com")!,
                        _ apiClient: HTTPClient = HTTPClientMock()) -> RemoteFeedLoader? {
        url = URL(string: "https://www.someOtherUrl.com")!
        client = HTTPClientMock()
        sut = RemoteFeedLoader(url, client)
        return sut
    }
    
}

class HTTPClientMock :HTTPClient {
    var invocationCount = 0
    var requestedUrl: URL?
    func get(from url: URL, completion: @escaping (FeedLoaderResponse) -> Void) {
        requestedUrl = url
        invocationCount += 1
    }
}
