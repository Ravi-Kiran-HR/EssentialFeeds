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
    
    init(session: URLSession){
        urlSession = session
    }
    
    func get(from url: URL) {
        urlSession.dataTask(with: url).resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_createsDataTaskWithURL()  {
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        let url = URL(string: "http://some_url")!
        sut.get(from: url)
        XCTAssertEqual(session.requestedUrls, [url])
    }
    
    func test_getFromURLResume_resumesDataTaskWithURL()  {
        let url = URL(string: "http://some_url")!
        let dataTask = URLSessionDataTaskSpy()
        let session = URLSessionSpy()
        session.stub(url: url, task: dataTask)
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)
        XCTAssertEqual(dataTask.resumeInvokeCounter, 1)
    }
}

class URLSessionSpy: URLSession {
    var requestedUrls = [URL]()
    private var stubs = [URL: URLSessionDataTask]()
    
    func stub(url: URL, task: URLSessionDataTask) {
        stubs[url] = task
    }
   
    override func dataTask(with url: URL) -> URLSessionDataTask {
        requestedUrls.append(url)
        return stubs[url] ?? FakeURLSessionDataTask()
    }
}

class URLSessionDataTaskSpy: URLSessionDataTask {
    var resumeInvokeCounter = 0
    override func resume() {
        resumeInvokeCounter += 1
    }
}

class FakeURLSessionDataTask: URLSessionDataTask {
    
}


