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
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping DeletionCompletion)
}
