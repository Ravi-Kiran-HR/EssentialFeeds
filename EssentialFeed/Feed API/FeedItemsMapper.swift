//
//  FeedItemsMapper.swift
//  EssentialFeeds
//
//  Created by Ravi Kiran HR on 18/02/22.
//

import Foundation

final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    static var OK_200: Int { 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard let root = try? JSONDecoder().decode(Root.self, from: data),
              response.statusCode == OK_200 else {
                  throw RemoteFeedLoader.Error.invalidData
              }
        return root.items
    }
}
