//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Ravi Kiran HR on 29/05/22.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrivalCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping DeletionCompletion)
    func retrieve(completion: @escaping RetrivalCompletion)
}

