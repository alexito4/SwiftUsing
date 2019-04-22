import SwiftSyntax

class UsingRewriter: SyntaxRewriter {
    
    var generated: [ExtensionDeclSyntax]
    
    public init(generated: [ExtensionDeclSyntax]) {
        self.generated = generated
    }
    
    func rewrite(_ tree: SourceFileSyntax) -> SourceFileSyntax {
        let updated = visit(tree) as! SourceFileSyntax
        let final = finallize(updated)
        return final
    }
    
    override func visit(_ node: ExtensionDeclSyntax) -> DeclSyntax {
        if let index = generated.firstIndex(where: { ext in
            return ext.extendedType.name == node.extendedType.name
        }), node.isGenerated {
            
            let existing = node
            let new = generated[index]
            
            generated.remove(at: index)
            
            return existing.withMembers(new.members)
        }
        return node
    }
    
    func finallize(_ tree: SourceFileSyntax) -> SourceFileSyntax {
        var node = tree
        for gen in generated {
            let final = gen.withLeadingComment("// generated")
            node = node.addCodeBlockItem(
                SyntaxFactory.makeCodeBlockItem(
                    item: final,
                    semicolon: nil, errorTokens: nil
                )
            )
        }
        return node
    }
}
