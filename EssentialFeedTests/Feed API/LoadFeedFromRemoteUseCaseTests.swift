//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedsTests
//
//  Created by Ravi Kiran HR on 15/02/22.
//

import XCTest
@testable import EssentialFeed

class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    
    func test_load_Invoked_with_URL() {
        let (sut, client) = makeSUT()
        sut.load{ _ in}
        XCTAssertNotNil(client.messages)
    }
    
    func test_load_Invoked_with_expected_URL() {
        let (sut, client) = makeSUT()
        sut.load{ _ in}
        XCTAssertEqual(client.requestedUrls[0], URL(string: "https://www.someOtherUrl.com")!)
    }
    
    func test_load_InvokedTwice_with_expected_URL_count() {
        let (sut, client) = makeSUT()
        sut.load{ _ in}
        sut.load{ _ in}
        XCTAssertEqual(client.requestedUrls.count, 2)
    }
    
    func test_load_InvokedTwice_with_expected_2URLs() {
        let (sut, client) = makeSUT()
        sut.load{ _ in}
        sut.load{ _ in}
        XCTAssertEqual(client.requestedUrls, [URL(string: "https://www.someOtherUrl.com")!,
                                              URL(string: "https://www.someOtherUrl.com")!])
    }
    
    func test_load_Invoked_expecting_connectivity_client_error() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: .failure(clientError))
        }
    }
    
    func test_load_delivers_non200HTTPResponseStatus() {
        let (sut, client) = makeSUT()
        [199, 202, 300, 400].enumerated().forEach { index , status in
            expect(sut, toCompleteWith: failure(.invalidData)){
                client.complete(with: status,
                                data: createItemsJSON([]),
                                at: index)
            }
        }
    }
    
    func test_load_delivers_200HTTPResponse_withInvalidJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: failure(.invalidData)) {
            let invalidJSON = Data("Invalid JSON".utf8)
            client.complete(with: 200, data: invalidJSON)
        }
    }
    
    func test_load_deliversNoItemsWith200HTTPResponseWithEmptyJSON() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = createItemsJSON([])
            client.complete(with: 200, data: emptyListJSON)
        }
    }
    
    func test_load_deliversItemsWith200HTTPResponseWithValidJSON() {
        let (sut, client) = makeSUT()
        
        let (item1, item1JSON) = createItem(id: UUID(),
                                            imageURL: URL(string: "www-a-url")!)
        
        let (item2, item2JSON) = createItem(id: UUID(),
                                            description: "a description",
                                            location: "a location",
                                            imageURL: URL(string: "www-another-url")!)
        
        let itemsJSONData = createItemsJSON([item1JSON, item2JSON])
        
        expect(sut, toCompleteWith: .success([item1, item2])) {
            client.complete(with: 200, data: itemsJSONData)
        }
    }
    
    func test_load_deliversNoItemsWith200HTTPResponseWhenFeedLoaderIsDeallocated() {
        let url = URL(string: "www-a-url")!
        let client = HTTPClientSpy()
        let (_, item1JSON) = createItem(id: UUID(),
                                        imageURL: URL(string: "www-a-url")!)
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url, client)
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }
        sut = nil
        client.complete(with: 200, data: createItemsJSON([item1JSON, item1JSON]))
        XCTAssertTrue(capturedResults.isEmpty)
    }
}

extension LoadFeedFromRemoteUseCaseTests {
    // SUTFactory
    private func makeSUT(_ url1: URL = URL(string: "https://www.someOtherUrl.com")!,
                           _ apiClient: HTTPClient = HTTPClientSpy()) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let url = URL(string: "https://www.someOtherUrl.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url, client)
        trackForMemoryLeak(client)
        trackForMemoryLeak(sut)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWith expectedResult: RemoteFeedLoader.Result,
                        when action:()->Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        
        let exp = expectation(description: "RemoteFeedLoader expecatation")
        sut.load { receivedResult in
            switch(receivedResult, expectedResult){
            case let(.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let(.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("expectd\(expectedResult) but received \(receivedResult) instead")
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
    
    private func createItem(id: UUID,
                            description: String? = nil,
                            location: String? = nil,
                            imageURL: URL) -> (FeedItem, [String: String]) {
        
        let item = FeedItem(id: id,
                            description: description,
                            location: location,
                            imageURL: imageURL)
        
        let itemJSON = ["id": item.id.uuidString,
                        "description": item.description,
                        "location": item.location,
                        "image": item.imageURL.absoluteString].compactMapValues { $0 }
        
        
        return (item, itemJSON)
    }
    
    private func createItemsJSON(_ JSONObjs: [[String: Any]]) -> Data {
        return  try! JSONSerialization.data(withJSONObject: ["items": JSONObjs])
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
       return .failure(error)
    }
}

class HTTPClientSpy :HTTPClient {
    var messages = [(url: URL,
                     completion: (HTTPClientResult) -> Void)]()
    var requestedUrls: [URL] {
        return messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(with response: HTTPClientResult,
                  at index: Int = 0) {
        messages[index].completion(response)
    }
    
    func complete(with statusCode: Int,
                  data: Data,
                  at index: Int = 0) {
        let httpResponse = HTTPURLResponse(url: requestedUrls[0], statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success((data, httpResponse)))
    }
}
