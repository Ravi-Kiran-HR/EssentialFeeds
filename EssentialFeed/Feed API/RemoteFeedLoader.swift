//
//  RemoteFeedLoader.swift
//  EssentialFeeds
//
//  Created by Ravi Kiran HR on 15/02/22.
//

import Foundation

final public class RemoteFeedLoader: FeedLoader {
    let apiClient: HTTPClient
    let url: URL
    public typealias Result = LoadFeedResult
    
    public init(_ url: URL, _ apiClient: HTTPClient) {
        self.apiClient = apiClient
        self.url = url
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        apiClient.get(from: url) { [weak self] response in
            guard self != nil else { return }
            switch response {
            case let .success((data, response)):
                do {
                    let remoteFeedItems = try FeedItemsMapper.map(data, response)
                    completion(.success(remoteFeedItems.toFeedItems()))
                } catch {
                    completion(.failure(error))
                }
             case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toFeedItems() -> [FeedItem] {
        return map { FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image) }
    }
}



