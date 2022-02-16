//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedsTests
//
//  Created by Ravi Kiran HR on 15/02/22.
//

import XCTest
@testable import EssentialFeeds

class RemoteFeedLoaderTests: XCTestCase {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    override func setUpWithError() throws {
    }
    
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    override func tearDownWithError() throws {
    }
    
    func test_load_Invoked_with_URL() {
        let (sut, client) = makeSUT()
        sut?.load()
        XCTAssertNotNil(client.requestedUrl)
    }
    
    func test_load_Invoked_with_expected_URL() {
        let (sut, client) = makeSUT()
        sut?.load()
        XCTAssertEqual(client.requestedUrl, URL(string: "https://www.someOtherUrl.com")!)
    }
    
    func test_load_InvokedTwice_with_expected_2URLs() {
        let (sut, client) = makeSUT()
        sut?.load()
        sut?.load()
        XCTAssertEqual(client.invocationCount, 2)
    }
    
    func test_load_Invoked_expecting_error() {
        let (sut, client) = makeSUT()
        sut?.load()
        XCTAssertEqual(URL(string: "https://www.someOtherUrl.com")!, client.requestedUrl)
    }
    
    // SUTFactory
    private func makeSUT(_ url1: URL = URL(string: "https://www.someOtherUrl.com")!,
                         _ apiClient: HTTPClient = HTTPClientMock()) -> (sut: RemoteFeedLoader?, client: HTTPClientMock) {
        let url = URL(string: "https://www.someOtherUrl.com")!
        let client = HTTPClientMock()
        let sut = RemoteFeedLoader(url, client)
        return (sut, client)
    }
    
}

class HTTPClientMock :HTTPClient {
    var invocationCount = 0
    var requestedUrl: URL?
    func get(from url: URL, completion: @escaping (FeedLoaderResponse) -> Void) {
        requestedUrl = url
        invocationCount += 1
        completion(.failure(.invalidRequest))
    }
}
