//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Ravi Kiran HR on 09/10/23.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }
    private struct CodableFeedImage: Codable {
        private var id: UUID
        private var description: String?
        private var location: String?
        private var url: URL
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
        
        init( _ local: LocalFeedImage) {
            self.id = local.id
            self.description = local.description
            self.location = local.location
            self.url = local.url
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping FeedStore.RetrivalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        let cache = try! JSONDecoder().decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.DeletionCompletion) {
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! JSONEncoder().encode(cache)
        try? encoded.write(to: storeURL)
        completion(nil)
    }
}

final class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        setupEmptyStoreState()
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "retrieve value expectation")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("expected empty but got a \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "retrieve value expectation")
        sut.retrieve { firstResult in
            sut.retrieve { secResult in
                switch (firstResult, secResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("expected empty but got a \(firstResult) and \(secResult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_retrieve_afterInsertingToEmptyCache_deliversInsertedValue() {
        let sut = makeSUT()
        let exp = expectation(description: "retrieve value expectation")
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError)
            sut.retrieve { retrievedResult in
                switch retrievedResult {
                case let .found(retrievedFeed, retrievedTimestamp):
                    XCTAssertEqual(retrievedFeed, feed)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                    break
                default:
                    XCTFail("expected a \(feed) and a \(timestamp) but got a \(retrievedResult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1)
    }
    
    private func setupEmptyStoreState() {
        do {
            try FileManager.default.removeItem(at: storeURL)
            print("## removed item at path: \(storeURL)")
        }
        catch (let error) {
            print("## error: \(error)")
        }
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let store = CodableFeedStore(storeURL: storeURL)
        trackForMemoryLeak(store)
        return store
    }
    
    private var storeURL: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
