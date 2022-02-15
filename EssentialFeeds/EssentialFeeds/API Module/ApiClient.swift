//
//  ApiClient.swift
//  EssentialFeeds
//
//  Created by Ravi Kiran HR on 15/02/22.
//

import Foundation

protocol ApiClient {
    func load(url:URL, completion: () -> Void)
}

class HTTPClient: ApiClient {
    var requestedURL: URL?
    func load(url:URL, completion: () -> Void){
        
    }
}
