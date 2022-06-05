//
//  HTTPClient.swift
//  EssentialFeeds
//
//  Created by Ravi Kiran HR on 18/02/22.
//

import Foundation

public typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
