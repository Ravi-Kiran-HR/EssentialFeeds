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
    private struct UnexpectedValueRepresentation: Error {}
    
    init(session: URLSession = .shared) {
        urlSession = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        urlSession.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, data.count > 0, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            }
            else {
                completion(.failure(UnexpectedValueRepresentation()))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_performsGetRequestWithURL() {
        let url = anyURL()
        let stubError = NSError(domain: "InvalidRequest", code: 12, userInfo: nil)
        URLProtocolStub.stub(data: nil, response: nil, error: stubError)
        let exp = expectation(description: "Expectation")
        makeSUT().get(from: url) { _ in }
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url, url)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3)
    }
    
    func test_getFromURL_completesGetRequestWithValidData() {
        let stubData = anyData()
        let stubResponse = anyHTTPURLResponse()
        URLProtocolStub.stub(data: stubData, response: anyHTTPURLResponse(), error: nil)
        let exp = expectation(description: "Expectation")
        makeSUT().get(from: anyURL()) { response in
            switch response {
            case let .success(receivedData, receivedResponse):
                XCTAssertEqual(receivedData, stubData)
                XCTAssertEqual(receivedResponse.statusCode, stubResponse.statusCode)
                XCTAssertEqual(receivedResponse.url, stubResponse.url)
            default:
                break
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3)
    }
    
    func test_getFromURL_returnsErrorWithInvalidRequest() {
        let requestError = NSError(domain: "InvalidRequest", code: 12, userInfo: nil)
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as NSError?
        XCTAssertEqual(requestError.domain, receivedError?.domain)
    }
    
    func test_getFromURL_returnsErrorWithAllNilValues() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
    }
    
    func test_getFromURL_failsForAllInvalidDataRepresentations() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromURL_succeedsWithValidDataAndResponse() {
        let anyData = anyData()
        let anyResponse = anyHTTPURLResponse()
        URLProtocolStub.stub(data: anyData, response: anyResponse, error: nil)
        
        let sut = makeSUT()
        let exp = expectation(description: "wait for success")
        sut.get(from: anyURL()) { response in
            switch(response){
            case let .success(data, response):
                XCTAssertEqual(data, anyData)
                XCTAssertEqual(response.statusCode, anyResponse.statusCode)
                XCTAssertEqual(response.url, anyResponse.url)
                
            default:
                XCTFail("expecting success got failure")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    private func resultErrorFor(data: Data?,
                                response: URLResponse?,
                                error: Error?,
                                file: StaticString = #filePath,
                                line: UInt = #line) -> Error? {
        
        URLProtocolStub.stub(data: data, response: response, error: error)
        let exp = expectation(description: "Expectation")
        var receivedError: Error?
        let sut = makeSUT(file: file, line: line)
        sut.get(from: anyURL()) { response in
            switch response {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expecting the error but got \(response) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return receivedError
    }
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any_url")!
    }
    
    private func anyData() -> Data {
        return Data("any_data".utf8)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "InvalidRequest", code: 12, userInfo: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 1, textEncodingName: nil)
        
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
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
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



