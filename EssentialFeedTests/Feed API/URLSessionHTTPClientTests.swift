//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedsTests
//
//  Created by Ravi Kiran HR on 05/03/22.
//

import XCTest

@testable import EssentialFeed

class URLSessionHTTPClient {
    private let urlSession: URLSession
    
    init(session: URLSession = .shared) {
        urlSession = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        urlSession.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
        func test_getFromURL_performsGetRequestWithURL() {
        let url = URL(string: "http://some_url")!
        let stubError = NSError(domain: "InvalidRequest", code: 12, userInfo: nil)
        URLProtocolStub.stub(url: url, data: nil, response: nil, error: stubError)
        let exp = expectation(description: "Expectation")
        makeSUT().get(from: url) { _ in }
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url, url)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3)
    }
    
    func test_getFromURL_returnsErrorWithInvalidRequest() {
        let url = URL(string: "http://some_url")!
        let stubError = NSError(domain: "InvalidRequest", code: 12, userInfo: nil)
        URLProtocolStub.stub(url: url, data: nil, response: nil, error: stubError)
        let exp = expectation(description: "Expectation")
        makeSUT().get(from: url) { response in
            switch response {
            case let .failure(error as NSError):
                XCTAssertEqual(stubError.domain, error.domain)
            default:
                XCTFail("Expecting the error \(stubError)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3)
    }
    
    private func makeSUT() -> URLSessionHTTPClient {
        return URLSessionHTTPClient()
    }
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startIntercepting()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopIntercepting()
    }
}

class URLProtocolStub: URLProtocol {
    private static var stub :Stub?
    private static var requestObserver: ((URLRequest) -> Void)?
    private struct Stub {
        let data: Data?
        let error: Error?
        let response: URLResponse?
    }
    
    static func stub(url: URL, data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(data: data, error: error, response: response)
    }
    
    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        requestObserver = observer
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        requestObserver?(request)
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let stub = URLProtocolStub.stub else { return }
        
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
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
        stub = nil
        requestObserver = nil
    }
}



