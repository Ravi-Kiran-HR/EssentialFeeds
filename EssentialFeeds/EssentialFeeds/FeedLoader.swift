//
//  FeedLoader.swift
//  EssentialFeeds
//
//  Created by Ravi Kiran HR on 15/02/22.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
