//
//  FeedCacheTestHelper.swift
//  EssentialFeedTests
//
//  Created by Ravi Kiran HR on 30/09/23.
//

import Foundation
import EssentialFeed

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let items = [uniqueImage(), uniqueImage()]
    let localItems = items.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    return (items, localItems)
}

func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), description: nil, location: nil, url: anyURL())
}

public extension Date {
    func adding(days: Int) -> Date {
        return Calendar.init(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
