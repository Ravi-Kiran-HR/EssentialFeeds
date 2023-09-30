//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Ravi Kiran HR on 30/09/23.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "InvalidRequest", code: 12, userInfo: nil)
}

func anyURL() -> URL {
    return URL(string: "http://any_url")!
}
