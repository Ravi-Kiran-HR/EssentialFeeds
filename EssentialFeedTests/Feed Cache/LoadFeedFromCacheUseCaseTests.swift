//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Ravi Kiran HR on 05/06/22.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsWithRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        let exp = expectation(description: "wait for exp")
        var receivedError: Error?
        
        sut.load() { result in
            switch result {
            case .failure(let error):
                receivedError = error
            default:
                XCTFail("expected failure got \(result) instead")
            }
            
            exp.fulfill()
        }
        store.completeRetrival(with: retrievalError)
        wait(for: [exp], timeout: 1)
                
        XCTAssertEqual(receivedError as NSError?, retrievalError)
    }
    
    func test_load_deliversNoFeedImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        var retrievedImages: [FeedImage]?
        let expectedImages: [FeedImage] = []
        
        let exp = expectation(description: "wait for exp")
        
        sut.load() { result in
            switch result {
            case .success(let feeds):
                retrievedImages = feeds
            default:
                XCTFail("expected success got \(result) instead")
            }
            
            exp.fulfill()
        }
        store.completeRetrivalWithEmptyCache()
        wait(for: [exp], timeout: 1)
                
        XCTAssertEqual(retrievedImages, expectedImages)
    }

    private func makeSUT(currentDate: @escaping () -> Date = Date.init,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "InvalidRequest", code: 12, userInfo: nil)
    }
    
    private func uniqueImage() -> FeedImage {
        FeedImage(id: UUID(), description: nil, location: nil, url: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any_url")!
    }

}
