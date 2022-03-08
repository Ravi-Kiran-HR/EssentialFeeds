//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedsTests
//
//  Created by Ravi Kiran HR on 05/03/22.
//

import XCTest

@testable import EssentialFeeds

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask
}

protocol HTTPSessionDataTask {
    func resume()
}

class URLSessionHTTPClient {
    private let urlSession: HTTPSession
    
    init(session: HTTPSession){
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
    
    func test_getFromURLResume_resumesDataTaskWithURL() {
        let url = URL(string: "http://some_url")!
        let dataTask = HTTPSessionDataTaskSpy()
        let session = HTTPSessionSpy()
        session.stub(url: url, task: dataTask)
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url) { _ in }
        XCTAssertEqual(dataTask.resumeInvokeCounter, 1)
    }
    
    func test_getFromURL_returnsErrorWithInvalidRequest() {
        let url = URL(string: "http://some_url")!
        let stubError = NSError(domain: "InvalidRequest", code: 12, userInfo: nil)
        let session = HTTPSessionSpy()
        session.stub(url: url, error: stubError)
        let sut = URLSessionHTTPClient(session: session)
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
        wait(for: [exp], timeout: 1)
    }
}

class HTTPSessionSpy: HTTPSession {
    private var stubs = [URL: Stub]()
    private struct Stub {
        let task: HTTPSessionDataTask
        let error: Error?
    }
    
    func stub(url: URL, task: HTTPSessionDataTask = FakeHTTPSessionDataTask(), error: Error? = nil) {
        let stub = Stub(task: task, error: error)
        stubs[url] = stub
    }
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask {
        guard let stub = stubs[url] else {
            fatalError("Stub should be provided")
        }
        completionHandler(nil, nil, stub.error)
        return stub.task
    }
}

class HTTPSessionDataTaskSpy: HTTPSessionDataTask {
    var resumeInvokeCounter = 0
    
    func resume() {
        resumeInvokeCounter += 1
    }
}

class FakeHTTPSessionDataTask: HTTPSessionDataTask {
    func resume() {}
}


