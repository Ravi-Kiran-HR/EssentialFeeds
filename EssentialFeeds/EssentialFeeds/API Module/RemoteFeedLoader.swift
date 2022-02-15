//
//  RemoteFeedLoader.swift
//  EssentialFeeds
//
//  Created by Ravi Kiran HR on 15/02/22.
//

import Foundation

class RemoteFeedLoader {
    let apiClient: HTTPClient
    let url: URL
    
    init(_ url: URL, _ apiClient: HTTPClient) {
        self.apiClient = apiClient
        self.url = url
    }
    
    func load() {
        apiClient.get(from: url)
    }
}
