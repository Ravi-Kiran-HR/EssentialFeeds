//
//  ApiClient.swift
//  EssentialFeeds
//
//  Created by Ravi Kiran HR on 15/02/22.
//

import Foundation

protocol HTTPClient {
    func get(from url:URL)
}

class apiClient: HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
        self.requestedURL = url
    }   
}
