//
//  FeedItem.swift
//  EssentialFeeds
//
//  Created by Ravi Kiran HR on 15/02/22.
//

import Foundation

public struct FeedItem: Equatable {
    
    public init(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
    
    var id: UUID
    var description: String?
    var location: String?
    var imageURL: URL
    
}

