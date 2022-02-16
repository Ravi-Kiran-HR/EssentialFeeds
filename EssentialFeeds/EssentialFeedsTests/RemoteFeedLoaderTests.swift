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
        let (sut, client) = createSUT()
        sut?.load()
        XCTAssertNotNil(client.requestedUrl)
    }
    
    func test_load_Invoked_with_expected_URL() {
        let (sut, client) = createSUT()
        sut?.load()
        XCTAssertEqual(client.requestedUrl, URL(string: "https://www.someOtherUrl.com")!)
    }
    
    func test_load_InvokedTwice_with_expected_2URLs() {
        let (sut, client) = createSUT()
        sut?.load()
        sut?.load()
        XCTAssertEqual(client.invocationCount, 2)
    }
    
    func test_load_Invoked_expecting_connectivity_error() {
        let (sut, client) = createSUT()
        client.error = NSError(domain: "Test", code: 0)
        var capturedError: RemoteFeedLoader.Error?
        
        sut?.load(completion: { error in
            capturedError = error
        })
        XCTAssertTrue(capturedError == .connectivity)
    }
    
    // SUTFactory
    private func createSUT(_ url1: URL = URL(string: "https://www.someOtherUrl.com")!,
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
    var error: Error?
//    var messages = [(url: URL, completion: (FeedLoaderResponse) -> Void)] ()
    
    func get(from url: URL, completion: @escaping (Error) -> Void) {
        requestedUrl = url
        invocationCount += 1
        
        if let error = error {
            completion(error)
        }
        
//        messages.append ((url, completion))
    }
    
//    func getResponseBlock(with error: HTTPClientError, atIndex: Int = 0) -> (url: URL, completion: (FeedLoaderResponse) -> Void){
//        return messages[atIndex].completion(error)
//    }
}
