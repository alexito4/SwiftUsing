import SwiftSyntax
import Foundation

public class SwiftUsing {
    
    let file: URL
    
    public init(file: URL) {
        self.file = file
    }
    
    public func generate() throws {
        // Parse file
        let tree = try SyntaxTreeParser.parse(file)
        
        // File -> UsingFinder Visitor -> (types + using)
        let (types, using) = find(tree)
        
        // (types + using) -> Maker -> [ExtensionDeclSyntax]
        let generated = make(types: types, using: using)

        // Tree + [ExtensionDeclSyntax] -> Rewritter -> new Tree
        let newTree = rewritte(tree, generated: generated)
            
        // Overwrite file
        try "\(newTree)".write(to: file, atomically: true, encoding: .utf8)
    }
    
    func find(_ tree: SourceFileSyntax) -> (
        types: [StructDeclSyntax],
        using: [VariableDeclSyntax]
    ) {
        let visitor = UsingFinder()
        tree.walk(visitor)
        
        return (
            visitor.types,
            visitor.using
        )
    }
    
    func make(
        types: [StructDeclSyntax],
        using: [VariableDeclSyntax]
    ) -> [ExtensionDeclSyntax] {
        let maker = UsingMaker(types: types, using: using)
        return maker.generateUsingCode()
    }
    
    func rewritte(_ tree: SourceFileSyntax, generated: [ExtensionDeclSyntax]) -> SourceFileSyntax {
        let rewriter = UsingRewriter(generated: generated)
        let final = rewriter.rewrite(tree)
        return final
    }
    
}
