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
        sut.load{ _ in}
        XCTAssertNotNil(client.messages)
    }
    
    func test_load_Invoked_with_expected_URL() {
        let (sut, client) = createSUT()
        sut.load{ _ in}
        XCTAssertEqual(client.requestedUrls[0], URL(string: "https://www.someOtherUrl.com")!)
    }
    
    func test_load_InvokedTwice_with_expected_URL_count() {
        let (sut, client) = createSUT()
        sut.load{ _ in}
        sut.load{ _ in}
        XCTAssertEqual(client.requestedUrls.count, 2)
    }
    
    func test_load_InvokedTwice_with_expected_2URLs() {
        let (sut, client) = createSUT()
        sut.load{ _ in}
        sut.load{ _ in}
        XCTAssertEqual(client.requestedUrls, [URL(string: "https://www.someOtherUrl.com")!,URL(string: "https://www.someOtherUrl.com")!])
    }
    
    func test_load_Invoked_expecting_connectivity_client_error() {
        let (sut, client) = createSUT()
        expect(sut, toCompleteWithError: .invalidData) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: .failure(clientError))
        }
    }
    
    func test_load_Invoked_expecting_non200HTTPResponseStatus() {
        let (sut, client) = createSUT()
        [199, 202, 300, 400].enumerated().forEach { index , status in
            expect(sut, toCompleteWithError: .invalidData) {
                client.complete(with: status, at: index)
            }
        }
    }
    
    func test_load_Invoked_returns200HTTPResponse_withInvalidJSON() {
        let (sut, client) = createSUT()
        expect(sut, toCompleteWithError: .invalidData) {
            let invalidJSON = Data("Invalid JSON".utf8)
            client.complete(with: 200, data: invalidJSON)
        }
    }
}

extension RemoteFeedLoaderTests {
    // SUTFactory
    private func createSUT(_ url1: URL = URL(string: "https://www.someOtherUrl.com")!,
                           _ apiClient: HTTPClient = HTTPClientSpy()) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let url = URL(string: "https://www.someOtherUrl.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url, client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWithError error: RemoteFeedLoader.Error,
                        when action:()->Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load { capturedError.append($0) }
        action()
        XCTAssertTrue(capturedError == [error], file: file, line: line)
    }
}

class HTTPClientSpy :HTTPClient {
    var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
    var requestedUrls: [URL] {
        return messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(with response: HTTPClientResult, at index: Int = 0){
        messages[index].completion(response)
    }
    
    func complete(with statusCode: Int, data: Data = Data(), at index: Int = 0){
        let httpResponse = HTTPURLResponse(url: requestedUrls[0], statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success(data, httpResponse))
    }
}
