//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Ravi Kiran HR on 09/10/23.
//

import XCTest
import EssentialFeed

class CoadableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrivalCompletion) {
        completion(.empty)
    }
}

final class CodableFeedStoreTests: XCTestCase {

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CoadableFeedStore()
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
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CoadableFeedStore()
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

}
