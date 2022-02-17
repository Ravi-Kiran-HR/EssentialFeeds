//
//  RemoteFeedLoader.swift
//  EssentialFeeds
//
//  Created by Ravi Kiran HR on 15/02/22.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url:URL,completion: @escaping (HTTPClientResult) -> Void)
}

final public class RemoteFeedLoader {
    let apiClient: HTTPClient
    let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    init(_ url: URL, _ apiClient: HTTPClient) {
        self.apiClient = apiClient
        self.url = url
    }
    
    func load(completion: @escaping (Result) -> Void) {
        apiClient.get(from: url) { response in
            switch response {
            case let .success(data, _):
                if let _ = try? JSONSerialization.jsonObject(with: data){
                    completion(.success([]))
                } else {
                    completion(.failure(.invalidData))
                }
                break
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
