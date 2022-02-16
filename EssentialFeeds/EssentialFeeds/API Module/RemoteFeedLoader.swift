//
//  RemoteFeedLoader.swift
//  EssentialFeeds
//
//  Created by Ravi Kiran HR on 15/02/22.
//

import Foundation

public protocol HTTPClient {
    func get(from url:URL,completion: @escaping (Error) -> Void)
}

final public class RemoteFeedLoader {
    let apiClient: HTTPClient
    let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    init(_ url: URL, _ apiClient: HTTPClient) {
        self.apiClient = apiClient
        self.url = url
    }
    
    func load(completion: @escaping (Error) -> Void) {
        apiClient.get(from: url) { error in
            completion(.connectivity)
        }
    }
}
