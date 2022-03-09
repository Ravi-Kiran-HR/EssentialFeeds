//
//  FeedItemsMapper.swift
//  EssentialFeeds
//
//  Created by Ravi Kiran HR on 18/02/22.
//

import Foundation

final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
        var feed: [FeedItem] {
            items.map{ $0.item }
        }
    }
    
    private struct Item: Decodable {
        var id: UUID
        var description: String?
        var location: String?
        var image: URL
        
        var item: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    static var OK_200: Int { 200 }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard let root = try? JSONDecoder().decode(Root.self, from: data),
              response.statusCode == OK_200 else {
                  return .failure(RemoteFeedLoader.Error.invalidData)
              }
        return .success(root.feed)
    }
}
