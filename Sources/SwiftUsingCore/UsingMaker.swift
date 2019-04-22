import SwiftSyntax

class UsingMaker {
    
    let types: [StructDeclSyntax]
    let using: [VariableDeclSyntax]
    
    init(types: [StructDeclSyntax], using: [VariableDeclSyntax]) {
        self.types = types
        self.using = using
    }
    
    func generateUsingCode() -> [ExtensionDeclSyntax] {
        return using
            .compactMap({ generateUsingCode(for: $0) })
    }
    
    func generateUsingCode(for node: VariableDeclSyntax) -> ExtensionDeclSyntax? {
        guard let parentName = node.structDeclaration?.identifier else { return nil }

        let usingMember = node.asStructMember
        
        guard let usingType = types.first(where: { $0.identifier.text == usingMember.type }) else {
            print("Error: Declaration for \(usingMember.type) not found.")
            return nil
        }
        
        let members = usingType.structMembers
        
        // Old ugly prorotype code. What a pain to cast all the time.
//        let members = usingType.members.children
//            .compactMap({ ($0 as? MemberDeclListSyntax)?.children })
//            .flatMap({ $0 })
//            .compactMap({ $0 as? MemberDeclListItemSyntax })
//            .flatMap({ $0.children })
//            .map({ $0 as! VariableDeclSyntax })
//            .flatMap({ $0.bindings.children.compactMap({ $0 as? PatternBindingSyntax }) })
//            .compactMap({ m -> (String, String)? in
//                var identifier: String?
//                var theType: String?
//                for part in m.children {
//                    if let i = part as? IdentifierPatternSyntax {
//                        identifier = i.identifier.text
//                    }
//                    if let t = part as? TypeAnnotationSyntax {
//                        let tttt = t.type.child(at: 0) as! TokenSyntax
//                        theType = tttt.text
//                    }
//                }
//                if let id = identifier, let t = theType {
//                    return (id, t)
//                } else {
//                    return nil
//                }
//            })
        
        let ext = SyntaxFactory.makeUsingExtensionDecl(
            members: members,
            variable: usingMember,
            parentName: parentName.text
        )
        return ext
    }
}
