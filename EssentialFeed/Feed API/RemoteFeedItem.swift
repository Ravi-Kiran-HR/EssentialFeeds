//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Ravi Kiran HR on 05/06/22.
//

import Foundation

struct RemoteFeedItem: Decodable {
    var id: UUID
    var description: String?
    var location: String?
    var image: URL
}
