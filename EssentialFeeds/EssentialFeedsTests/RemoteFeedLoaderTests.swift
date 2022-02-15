//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedsTests
//
//  Created by Ravi Kiran HR on 15/02/22.
//

import XCTest
@testable import EssentialFeeds

class RemoteFeedLoaderTests: XCTestCase {

    let sut: RemoteFeedLoader? = nil
    let client: HTTPClient? = nil
    // Put setup code here. This method is called before the invocation of each test method in the class.
    override func setUpWithError() throws {
    }

    // Put teardown code here. This method is called after the invocation of each test method in the class.
    override func tearDownWithError() throws {
        
    }
     
    func test_init_DoesNotRequestDataFromURL() {
        XCTAssertNil(client?.requestedURL)
    }
    

}
