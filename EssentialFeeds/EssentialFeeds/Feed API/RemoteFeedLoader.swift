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
    typealias Result = LoadFeedResult<Error>
    
    init(_ url: URL, _ apiClient: HTTPClient) {
        self.apiClient = apiClient
        self.url = url
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    func load(completion: @escaping (Result) -> Void) {
        apiClient.get(from: url) {[weak self] response in
            guard self != nil else { return }
            switch response {
            case let .success(data, response):
                completion(FeedItemsMapper.map(data, response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}



