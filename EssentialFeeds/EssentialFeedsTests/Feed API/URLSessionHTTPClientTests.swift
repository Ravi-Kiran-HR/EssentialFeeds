//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedsTests
//
//  Created by Ravi Kiran HR on 05/03/22.
//

import XCTest

@testable import EssentialFeeds

class URLSessionHTTPClient {
    private let urlSession: URLSession
    
    init(session: URLSession = .shared) {
        urlSession = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        urlSession.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_returnsErrorWithInvalidRequest() {
        URLProtocolStub.startIntercepting()
        let url = URL(string: "http://some_url")!
        let stubError = NSError(domain: "InvalidRequest", code: 12, userInfo: nil)
        URLProtocolStub.stub(url: url, error: stubError)
        let sut = URLSessionHTTPClient()
        let exp = expectation(description: "Expectation")
        sut.get(from: url) { response in
            switch response {
            case let .failure(error as NSError):
                XCTAssertEqual(stubError.domain, error.domain)
            default:
                XCTFail("Expecting the error \(stubError)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3)
        URLProtocolStub.stopIntercepting()
    }
}

class URLProtocolStub: URLProtocol {
    private static var stubs = [URL: Stub]()
    private struct Stub {
        let error: Error?
    }
    
    static func stub(url: URL, error: Error? = nil) {
        let stub = Stub(error: error)
        stubs[url] = stub
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else { return false }
        return stubs[url] == nil
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override class func canInit(with task: URLSessionTask) -> Bool {
        return true
    }
    
    override func startLoading() {
        guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
    
    static func startIntercepting() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopIntercepting() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }
}




