//
//  XCTests+MemoryTracker.swift
//  EssentialFeedTests
//
//  Created by Ravi Kiran HR on 09/03/22.
//

import Foundation
import XCTest

extension XCTestCase {
     func trackForMemoryLeak(_ object: AnyObject,
                                    file: StaticString = #filePath,
                                    line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "sut object should have been deallocated, potential memory leak", file: file, line: line)
        }
    }
}
