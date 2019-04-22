/**
 *  UsingFinderTests
 *  Copyright (c) Alejandro Martínez 2019
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
import SnapshotTesting

@testable import SwiftUsingCore
import SwiftSyntax

class UsingFinderTests: XCTestCase {
    
    func testsFindsUsing() {
        let file = urlTempString("""
        struct A {}
        struct B {
            // using
            let a: A
        }
        // struct C {}
        struct D
        """)
        let tree = try! SyntaxTreeParser.parse(file)
        let visitor = UsingFinder()
        tree.walk(visitor)
        
        XCTAssertEqual(visitor.types.count, 2)
        XCTAssertEqual(visitor.using.count, 1)
    }
    
}

//extension SwiftUsingTests {
//    static var allTests: [(String, (SwiftUsingTests) -> () throws -> Void)] {
//        return [
//            ("testExample", testExample),
//            ("testPerformanceExample", testPerformanceExample)
//        ]
//    }
//}
