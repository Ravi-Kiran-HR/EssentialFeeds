//
//  RemoteFeedLoader.swift
//  EssentialFeeds
//
//  Created by Ravi Kiran HR on 15/02/22.
//

import Foundation

public enum HTTPClientError {
    case invalidRequest
    case noResponse
}

public enum FeedLoaderResponse {
    case success([FeedItem])
    case failure(HTTPClientError)
}

extension FeedLoaderResponse: Equatable {
    public static func == (lhs: FeedLoaderResponse, rhs: FeedLoaderResponse) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success):
            return true
        case (.failure(let a), .failure(let b)):
            return a == b
        case (.success, .failure):
            return false
        default:
            return false
        }
    }
    
    
}

public protocol HTTPClient {
    func get(from url:URL,completion: @escaping (FeedLoaderResponse) -> Void)
}

class RemoteFeedLoader {
    let apiClient: HTTPClient
    let url: URL
    
    init(_ url: URL, _ apiClient: HTTPClient) {
        self.apiClient = apiClient
        self.url = url
    }
    
    func load(completion: @escaping (FeedLoaderResponse) -> Void = { _ in}) {
        apiClient.get(from: url) { response in
            completion(response)
        }
    }
}
