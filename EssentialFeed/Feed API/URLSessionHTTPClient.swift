//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Ravi Kiran HR on 16/03/22.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let urlSession: URLSession
    private struct UnexpectedValueRepresentation: Error {}
    
    public init(session: URLSession = .shared) {
        urlSession = session
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        urlSession.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            }
            else {
                completion(.failure(UnexpectedValueRepresentation()))
            }
        }.resume()
    }
}
