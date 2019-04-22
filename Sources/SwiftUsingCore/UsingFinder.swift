import SwiftSyntax

/// Finds the required information to generate `using`
class UsingFinder: SyntaxVisitor {
    let usingMark = "// using"
    
    var types = [StructDeclSyntax]()
    var using = [VariableDeclSyntax]()
    
    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        types.append(node)
        return .visitChildren
    }
    
    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        
        if let comments = node.leadingTrivia?.compactMap({ piece -> String? in
            if case let TriviaPiece.lineComment(comment) = piece {
                return comment
            }
            return nil
        }), comments.first(where: { $0 == usingMark }) != nil {
            using.append(node)
        }
        
        return .visitChildren
    }
}
