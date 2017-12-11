//
//  SymbolTableBuilder.swift
//  SwiftPascalInterpreter
//
//  Created by Igor Kulman on 10/12/2017.
//  Copyright © 2017 Igor Kulman. All rights reserved.
//

import Foundation

public class SymbolTableBuilder {
    private let symbolTable = SymbolTable()

    public init() {

    }

    public func build(node: AST) -> SymbolTable {
        visit(node: node)
        return symbolTable
    }

    private func visit(node: AST) {
        switch node {
        case let .block(declarations: declarations, compound: compoundStatement):
            for declaration in declarations {
                visit(node: declaration)
            }
            visit(node: compoundStatement)
        case let .program(name: _, block: block):
            visit(node: block)
        case let .binaryOperation(left: left, operation: _, right: right):
            visit(node: left)
            visit(node: right)
        case .number:
            break
        case let .unaryOperation(operation: _, child: child):
            visit(node: child)
        case let .compound(children: children):
            for child in children {
                visit(node: child)
            }
        case .noOp:
            break
        case let .variable(name):
            guard symbolTable.lookup(name) != nil else {
                fatalError("Cannot use undeclared variable \(name)")
            }
        case let .variableDeclaration(name: variable, type: variableType):
            guard case let .variable(name) = variable, case let .type(type) = variableType else {
                fatalError()
            }
            switch type {
            case .integer:
                symbolTable.define(.variable(name: name, type: .integer))
            case .real:
                symbolTable.define(.variable(name: name, type: .real))
            }
        case let .assignment(left: left, right: right):
            guard case let .variable(name) = left else {
                fatalError("Assignment left side is not a variable")
            }
            guard symbolTable.lookup(name) != nil else {
                fatalError("Cannot assign to undeclared variable \(name)")
            }

            visit(node: right)
        case .type:
            break
        case .procedure:
            // TODO: local scope
            break
        }
    }
}