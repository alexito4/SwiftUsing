//
//  Syntax.swift
//  SnapshotTesting
//
//  Created by Alejandro Martinez on 21/04/2019.
//

import SwiftSyntax

extension Syntax {
    func printType() {
        print(type(of: self))
    }
}

extension VariableDeclSyntax {
    var structDeclaration: StructDeclSyntax? {
        var current: Syntax = self
        while let parent = current.parent {
            current = parent
            if let decl = current as? StructDeclSyntax {
                return decl
            }
        }
        return nil
    }
    
    var asStructMember: StructDeclSyntax.StructMember {
        guard let isVar = letOrVarKeyword.isVar else {
            fatalError("\(self) is not var or let")
        }
        
        let (id, type) = bindings.identifierAndType
        
        return .init(
            isVar: isVar,
            identifier: id,
            type: type
        )
    }
}

extension StructDeclSyntax {
    struct StructMember {
        let isVar: Bool // var or let
        let identifier: String
        let type: String
    }
    
    var structMembers: [StructMember] {
        let declarations: [VariableDeclSyntax] = members.members.declarations
        return declarations.reduce([]) { acc, decl in
            let member = decl.asStructMember
            return acc + [member]
        }
    }
}

extension PatternBindingListSyntax {
    var identifierAndType: (String, String) {
        guard let binding = child(at: 0) as? PatternBindingSyntax else {
            fatalError("Only supported single pattern binding.")
        }
        
        guard let identifier = (binding.pattern as? IdentifierPatternSyntax)?.identifier.text else {
            fatalError("Only supported IdentifierPatternSyntax")
        }
        
        guard let type = binding.typeAnnotation?.type.name else {
            fatalError("Pattern binding requires a type annotation")
        }
        
        return (identifier, type)
    }
}

extension MemberDeclListSyntax {
    var items: [MemberDeclListItemSyntax] {
        return children.compactMap({ $0 as? MemberDeclListItemSyntax })
    }
    var declarations: [VariableDeclSyntax] {
        return items.compactMap({ $0.decl as? VariableDeclSyntax })
    }
}

extension TokenSyntax {
    
    /// true if varKeyword, false if letKeyword, nil otherwise.
    var isVar: Bool? {
        switch tokenKind {
        case .varKeyword:
            return true
        case .letKeyword:
            return false
        default:
            return nil
        }
    }
}

extension TypeSyntax {
    var name: String {
        switch self {
        case let s as SimpleTypeIdentifierSyntax:
            return s.name.text
        default:
            fatalError("Can't get name from type. \(self)")
        }
    }
}

extension Trivia {
    static func newLine(indented: Int) -> Trivia {
        let tab = TriviaPiece.tabs(indented)
        return .init(arrayLiteral: .newlines(1), tab)
    }
}

extension ExtensionDeclSyntax {
    public func withLeadingComment(_ comment: String) -> ExtensionDeclSyntax {
        return withExtensionKeyword(
            extensionKeyword.withLeadingTrivia(
                .init(arrayLiteral:
                    .newlines(1),
                    .lineComment(comment),
                    .newlines(1)
                )
            )
        )
    }
    
    var isGenerated: Bool {
        return leadingTrivia?.contains(where: { piece in
            if case let TriviaPiece.lineComment(comment) = piece {
                return comment.contains("// generated")
            }
            return false
        }) == true
    }
}

extension SyntaxFactory {
    
    static func makeUsingExtensionDecl(
        members: [StructDeclSyntax.StructMember],
        variable: StructDeclSyntax.StructMember,
        parentName: String,
        indent: Int = 0
    ) -> ExtensionDeclSyntax {
        
        let vars = members.enumerated().map { i, member -> MemberDeclListItemSyntax in
            let id = member.identifier
            let type = member.type
            
            let computedProperty = makePatternBindingComputedProperty(
                variable: variable.identifier,
                id: id,
                type: type,
                makeSetter: member.isVar && variable.isVar, // Only generate setter if both the using member and the struct member are variables.
                indent: indent + 1
            )
            
            let generatedVariable = makeVariableDecl(
                attributes: nil,
                modifiers: nil,
                letOrVarKeyword: makeVarKeyword()
                    .withLeadingTrivia(.newLine(indented: indent + 1))
                    .withTrailingTrivia(.spaces(1)),
                bindings: makePatternBindingList([computedProperty])
            )
            
            return makeMemberDeclListItem(
                decl: generatedVariable, semicolon: nil
            )
        }
        
        return makeExtensionDecl(
            attributes: nil,
            modifiers: nil,
            extensionKeyword: makeExtensionKeyword(trailingTrivia: .spaces(1)),
            extendedType: makeTypeIdentifier(parentName, trailingTrivia: .spaces(1)),
            inheritanceClause: nil,
            genericWhereClause: nil,
            members: makeMemberDeclBlock(
                leftBrace: makeLeftBraceToken(),
                members: makeMemberDeclList(vars),
                rightBrace: makeRightBraceToken(leadingTrivia: .newlines(1))
            )
        )
    }
    
    static func makePatternBindingComputedProperty(
        variable: String,
        id: String,
        type: String,
        makeSetter: Bool,
        indent: Int
    ) -> PatternBindingSyntax {

        var list = [
            makeAccessorDeclGet(variable: variable, id: id, indent: indent + 1)
        ]
        if makeSetter {
            list.append(
                makeAccessorDeclSet(variable: variable, id: id, indent: indent + 1)
            )
        }
        
        let accessors = makeAccessorList(list)
        
        return makePatternBinding(
            pattern: makeIdentifierPattern(identifier: makeIdentifier(id)),
            typeAnnotation: makeTypeAnnotation(
                colon: makeColonToken().withTrailingTrivia(.spaces(1)),
                type: makeTypeIdentifier(type, trailingTrivia: .spaces(1))
            ),
            initializer: nil,
            accessor: makeAccessorBlock(
                leftBrace: makeLeftBraceToken(),
                accessors: accessors,
                rightBrace: makeRightBraceToken(leadingTrivia: .newLine(indented: indent))
            ),
            trailingComma: nil
        )
    }
    
    static func makeAccessorDeclGet(
        variable: String,
        id: String,
        indent: Int
    ) -> AccessorDeclSyntax {

        return makeAccessorDecl(
            attributes: nil,
            modifier: nil,
            accessorKind: makeContextualKeyword("get")
                .withLeadingTrivia(.newLine(indented: indent))
                .withTrailingTrivia(.spaces(1)),
            parameter: nil,
            body: makeCodeBlock(
                leftBrace: makeLeftBraceToken(),
                statements: makeCodeBlockItemList([
                    makeCodeBlockItem(item:
                        makeReturnStmt(
                            returnKeyword: makeReturnKeyword(
                                leadingTrivia: .newLine(indented: indent + 1),
                                trailingTrivia: .spaces(1)
                            ),
                            expression: makeMemberAccessExpr(
                                base: makeIdentifierExpr(identifier: makeIdentifier(variable), declNameArguments: nil),
                                dot: makePeriodToken(),
                                name: makeIdentifier(id),
                                declNameArguments: nil
                            )
                        ),
                                         semicolon: nil, errorTokens: nil)
                    ]),
                rightBrace: makeRightBraceToken(leadingTrivia: .newLine(indented: indent))
            )
        )
    }
    
    static func makeAccessorDeclSet(
        variable: String,
        id: String,
        indent: Int
    ) -> AccessorDeclSyntax {
        
        return makeAccessorDecl(
            attributes: nil,
            modifier: nil,
            accessorKind: makeContextualKeyword("set")
                .withLeadingTrivia(.newLine(indented: indent))
                .withTrailingTrivia(.spaces(1)),
            parameter: nil,
            body: makeCodeBlock(
                leftBrace: makeLeftBraceToken(),
                statements: makeCodeBlockItemList([
                    makeCodeBlockItem(
                        item: makeSequenceExpr(elements: makeExprList([
                            makeMemberAccessExpr(
                                base: makeIdentifierExpr(identifier: makeIdentifier(variable).withLeadingTrivia(.newLine(indented: indent + 1)), declNameArguments: nil),
                                dot: makePeriodToken(),
                                name: makeIdentifier(id).withTrailingTrivia(.spaces(1)),
                                declNameArguments: nil
                            ),
                            makeAssignmentExpr(assignToken: makeEqualToken().withTrailingTrivia(.spaces(1))),
                            makeIdentifierExpr(identifier: makeIdentifier("newValue"), declNameArguments: nil)
                        ])),
                        semicolon: nil, errorTokens: nil
                    ) // CodeBlockItemSyntax
                ]),
                rightBrace: makeRightBraceToken(leadingTrivia: .newLine(indented: indent))
            )
        )
    }
}
