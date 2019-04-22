/**
 *  UsingRewriterTests
 *  Copyright (c) Alejandro Martínez 2019
 *  Licensed under the MIT license. See LICENSE file.
 */

import XCTest
import SnapshotTesting

@testable import SwiftUsingCore
import SwiftSyntax

class UsingRewriterTests: XCTestCase {
    
    func testAddGeneratedExtension() throws {
        let file = urlTempString("""
        struct A { var name: String }
        struct B {
            // using
            var a: A
        }
        """)
        
        let (rewriter, tree) = rewriterFor(file: file)
        
        _assertInlineSnapshot(matching: rewriter.rewrite(tree), as: .description, with: """
        struct A { var name: String }
        struct B {
            // using
            var a: A
        }
        // generated
        extension B {
        	var name: String {
        		get {
        			return a.name
        		}
        		set {
        			a.name = newValue
        		}
        	}
        }
        """)
    }

    func testDontDuplicateGeneratedCode() throws {
        // File that already contains generated code
        let file = urlTempString("""
        struct A { var name: String }
        struct B {
            // using
            var a: A
        }
        // generated
        extension B {
            var name: String {
                get {
                    return a.name
                }
                set {
                    a.name = newValue
                }
            }
        }
        """)
        
        let (rewriter, tree) = rewriterFor(file: file)

        _assertInlineSnapshot(matching: rewriter.rewrite(tree), as: .description, with: """
        struct A { var name: String }
        struct B {
            // using
            var a: A
        }
        // generated
        extension B {
        	var name: String {
        		get {
        			return a.name
        		}
        		set {
        			a.name = newValue
        		}
        	}
        }
        """)
    }

    func testUpdateGeneratedCode() throws {
        // Prepare a file with outdated generated code
        let file = urlTempString("""
        struct A { var name: String }
        struct B {
            // using
            var a: A
        }
        // generated
        extension B {
            var other: String {
                get {
                    return a.other
                }
                set {
                    a.other = newValue
                }
            }
        }
        """)

        let (rewriter, tree) = rewriterFor(file: file)
        
        _assertInlineSnapshot(matching: rewriter.rewrite(tree), as: .description, with: """
        struct A { var name: String }
        struct B {
            // using
            var a: A
        }
        // generated
        extension B {
        	var name: String {
        		get {
        			return a.name
        		}
        		set {
        			a.name = newValue
        		}
        	}
        }
        """)
    }
    
    func testDontTouchOtherExtensionsCode() throws {
        // File that already contains generated code
        let file = urlTempString("""
        struct A { var name: String }
        struct B {
            // using
            var a: A
        }
        // generated
        extension B {
            var name: String {
                get {
                    return a.name
                }
                set {
                    a.name = newValue
                }
            }
        }
        extension B {
            func nothing() { }
        }
        """)
        
        let (rewriter, tree) = rewriterFor(file: file)
        
        _assertInlineSnapshot(matching: rewriter.rewrite(tree), as: .description, with: """
        struct A { var name: String }
        struct B {
            // using
            var a: A
        }
        // generated
        extension B {
        	var name: String {
        		get {
        			return a.name
        		}
        		set {
        			a.name = newValue
        		}
        	}
        }
        extension B {
            func nothing() { }
        }
        """)
    }
    
}

private func rewriterFor(file: URL) -> (UsingRewriter, SourceFileSyntax) {
    let tree = try! SyntaxTreeParser.parse(file)
    let visitor = UsingFinder()
    tree.walk(visitor)
    let maker = UsingMaker(types: visitor.types, using: visitor.using)
    let generated = maker.generateUsingCode()
    let rewriter = UsingRewriter(generated: generated)
    return (rewriter, tree)
}

//extension SwiftUsingTests {
//    static var allTests: [(String, (SwiftUsingTests) -> () throws -> Void)] {
//        return [
//            ("testExample", testExample),
//            ("testPerformanceExample", testPerformanceExample)
//        ]
//    }
//}
