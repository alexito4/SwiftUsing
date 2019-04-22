/**
 *  UsingMakerTests
 *  Copyright (c) Alejandro Martínez 2019
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
import SnapshotTesting

@testable import SwiftUsingCore
import SwiftSyntax

class UsingMakerTests: XCTestCase {
    
    // MARK: Generate code
    
    // TODO: a let shouldn't make a setter
    // TODO:         struct A { let name: String; let other: Int } crashes
    
    func testAllVars() {
        let file = urlTempString("""
        struct A {
            var name: String
            var other: Int
        }
        struct B {
            // using
            var a: A
        }
        """)
        
        let maker = makerFor(file: file)
        
        _assertInlineSnapshot(matching: maker.generateUsingCode(), as: .description, with: """
        [extension B {
        	var name: String {
        		get {
        			return a.name
        		}
        		set {
        			a.name = newValue
        		}
        	}
        	var other: Int {
        		get {
        			return a.other
        		}
        		set {
        			a.other = newValue
        		}
        	}
        }]
        """)
    }
    
    func testAllLets() {
        let file = urlTempString("""
        struct A {
            let name: String
            let other: Int
        }
        struct B {
            // using
            let a: A
        }
        """)
        
        let maker = makerFor(file: file)
        
        _assertInlineSnapshot(matching: maker.generateUsingCode(), as: .description, with: """
        [extension B {
        	var name: String {
        		get {
        			return a.name
        		}
        	}
        	var other: Int {
        		get {
        			return a.other
        		}
        	}
        }]
        """)
    }
    
    func testMainLetsUsingVars() {
        let file = urlTempString("""
        struct A {
            var name: String
            var other: Int
        }
        struct B {
            // using
            let a: A
        }
        """)
        
        let maker = makerFor(file: file)
        
        _assertInlineSnapshot(matching: maker.generateUsingCode(), as: .description, with: """
        [extension B {
        	var name: String {
        		get {
        			return a.name
        		}
        	}
        	var other: Int {
        		get {
        			return a.other
        		}
        	}
        }]
        """)
    }
    
    func testMainVarsUsingLets() {
        let file = urlTempString("""
        struct A {
            let name: String
            let other: Int
        }
        struct B {
            // using
            var a: A
        }
        """)
        
        let maker = makerFor(file: file)
        
        _assertInlineSnapshot(matching: maker.generateUsingCode(), as: .description, with: """
        [extension B {
        	var name: String {
        		get {
        			return a.name
        		}
        	}
        	var other: Int {
        		get {
        			return a.other
        		}
        	}
        }]
        """)
    }
}

private func makerFor(file: URL) -> UsingMaker {
    let tree = try! SyntaxTreeParser.parse(file)
    let visitor = UsingFinder()
    tree.walk(visitor)
    let maker = UsingMaker(types: visitor.types, using: visitor.using)
    return maker
}

//extension SwiftUsingTests {
//    static var allTests: [(String, (SwiftUsingTests) -> () throws -> Void)] {
//        return [
//            ("testExample", testExample),
//            ("testPerformanceExample", testPerformanceExample)
//        ]
//    }
//}
