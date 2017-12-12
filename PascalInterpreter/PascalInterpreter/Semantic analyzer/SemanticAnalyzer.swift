//
//  SymbolTableBuilder.swift
//  SwiftPascalInterpreter
//
//  Created by Igor Kulman on 10/12/2017.
//  Copyright © 2017 Igor Kulman. All rights reserved.
//

import Foundation

public class SemanticAnalyzer {
    private let symbolTable = ScopedSymbolTable(name: "global", level: 1)

    public init() {

    }

    public func build(node: AST) -> ScopedSymbolTable {
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
                fatalError("Symbol(indetifier) not found '\(name)'")
            }
        case let .variableDeclaration(name: variable, type: variableType):
            guard case let .variable(name) = variable, case let .type(type) = variableType else {
                fatalError("Invalid variable \(variable) or invalid type \(variableType)")
            }

            guard symbolTable.lookup(name) == nil else {
                fatalError("Duplicate identifier '\(name)' found")
            }

            guard let symbolType = symbolTable.lookup(type.description) else {
                fatalError("Type not found '\(type.description)'")
            }

            symbolTable.insert(.variable(name: name, type: symbolType))
        case let .assignment(left: left, right: right):
            visit(node: right)
            visit(node: left)
        case .type:
            break
        case let .procedure(name: name, params: params, block: _):
            var parameters: [Symbol] = []
            for param in params {
                guard case let .param(name: name, type: .type(type)) = param else {
                    fatalError("Only built int type parameters supported in procedure, got \(param)")
                }
                guard let symbol = symbolTable.lookup(type.description) else {
                    fatalError("Type not found '\(type.description)'")
                }
                parameters.append(.variable(name: name, type: symbol))
            }
            let symbol = Symbol.procedure(name: name, params: parameters)
            symbolTable.insert(symbol)
        case .param:
            break
        }
    }
}
