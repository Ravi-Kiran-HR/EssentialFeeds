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
            case let .success(data, response):
                do {
                    let feedItems = try FeedItemsMapper.map(data, response)
                    completion(.success(feedItems))
                }
                catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]
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
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map{ $0.item }
    }
}


