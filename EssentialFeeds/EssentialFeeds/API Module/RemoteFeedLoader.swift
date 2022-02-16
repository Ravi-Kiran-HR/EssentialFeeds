//
//  RemoteFeedLoader.swift
//  EssentialFeeds
//
//  Created by Ravi Kiran HR on 15/02/22.
//

import Foundation

public enum HTTPClientError {
    case invalidRequest
    case noresponse
}

public enum FeedLoaderResponse {
    case success([FeedItem])
    case failure(HTTPClientError)
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
    
    func load() {
        apiClient.get(from: url) { response in
//            switch response {
//            case .success([FeedItem]): break
//
//            case .failure(Error): break
//            }
        }
    }
}
