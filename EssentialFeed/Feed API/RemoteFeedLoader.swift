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
    
    public init(_ url: URL, _ apiClient: HTTPClient) {
        self.apiClient = apiClient
        self.url = url
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public func load(completion: @escaping (LoadFeedResult) -> Void) {
        apiClient.get(from: url) { [weak self] response in
            guard self != nil else { return }
            switch response {
            case let .success((data, response)):
                completion(RemoteFeedLoader.map(data, response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, _ response: HTTPURLResponse) -> LoadFeedResult {
        do {
            let remoteFeedItems = try FeedItemsMapper.map(data, response)
            return .success(remoteFeedItems.toFeedItems())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toFeedItems() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
    }
}



