/**
 *  SwiftUsing
 *  Copyright (c) Alejandro Martínez 2019
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
import SnapshotTesting

@testable import SwiftUsingCore
import SwiftSyntax

class SwiftUsingTests: XCTestCase {
    
}

func urlTempString(_ str: String) -> URL {
    let directory = NSTemporaryDirectory()
    let fileName = NSUUID().uuidString
    let fullURL = NSURL.fileURL(withPathComponents: [directory, fileName])!
    
    try! str.write(to: fullURL, atomically: true, encoding: .utf8)
    
    return fullURL
}

//extension SwiftUsingTests {
//    static var allTests: [(String, (SwiftUsingTests) -> () throws -> Void)] {
//        return [
//            ("testExample", testExample),
//            ("testPerformanceExample", testPerformanceExample)
//        ]
//    }
//}
