//
//  FeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Ravi Kiran HR on 24/05/22.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    let store: FeedStore
    init(store: FeedStore) {
        self.store = store
    }
    func save(_ item: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
    var insertionCallCount = 0
    
    func deleteCachedFeed() {
        deleteCachedFeedCallCount += 1
    }
    
    func completes(with error: NSError) {
        
    }
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_deleteCachedFeedCallCount() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        sut.save([uniqueFeedItem(), uniqueFeedItem()])
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    func test_save_doestNotRequestInsertionUponDeletionError() {
        let (sut, store) = makeSUT()
        store.completes(with: anyNSError())
        sut.save([uniqueFeedItem(), uniqueFeedItem()])
        XCTAssertEqual(store.insertionCallCount, 0)
    }
    
    
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> (LocalFeedLoader, FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeak(store, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        return (sut, store)
    }
    
    func uniqueFeedItem() -> FeedItem {
        FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any_url")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "InvalidRequest", code: 12, userInfo: nil)
    }
}
