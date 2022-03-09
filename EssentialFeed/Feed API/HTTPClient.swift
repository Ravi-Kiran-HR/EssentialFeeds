//
//  HTTPClient.swift
//  EssentialFeeds
//
//  Created by Ravi Kiran HR on 18/02/22.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url:URL, completion: @escaping (HTTPClientResult) -> Void)
}
