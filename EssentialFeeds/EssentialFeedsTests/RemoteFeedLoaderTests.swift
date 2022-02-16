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
        XCTAssertNotNil(client.requestedUrls)
    }
    
    func test_load_Invoked_with_expected_URL() {
        let (sut, client) = createSUT()
        sut?.load()
        XCTAssertEqual(client.requestedUrls[0], URL(string: "https://www.someOtherUrl.com")!)
    }
    
    func test_load_InvokedTwice_with_expected_URL_count() {
        let (sut, client) = createSUT()
        sut?.load()
        sut?.load()
        XCTAssertEqual(client.requestedUrls.count, 2)
    }
    
    func test_load_InvokedTwice_with_expected_2URLs() {
        let (sut, client) = createSUT()
        sut?.load()
        sut?.load()
        XCTAssertEqual(client.requestedUrls, [URL(string: "https://www.someOtherUrl.com")!,URL(string: "https://www.someOtherUrl.com")!])
    }
    
    func test_load_Invoked_expecting_connectivity_error() {
        let (sut, client) = createSUT()
        var capturedError = [RemoteFeedLoader.Error]()
        
        sut?.load(completion: {capturedError.append($0)})
        
        let clientError = NSError(domain: "Test", code: 0)
        client.completions[0](clientError)
        XCTAssertTrue(capturedError == [.connectivity])
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
    var requestedUrls =  [URL]()
    var completions = [(Error) -> Void]()
    
    func get(from url: URL, completion: @escaping (Error) -> Void) {
        requestedUrls.append(url)
        completions.append(completion)
    }
}
