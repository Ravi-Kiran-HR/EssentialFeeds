//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Ravi Kiran HR on 30/09/23.
//

import Foundation

final class FeedCachePolicy {
    private init() { }
    private static let calender = Calendar.init(identifier: .gregorian)
        
    private static var maxCacheAgeInDays: Int {
        return 7
    }
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
