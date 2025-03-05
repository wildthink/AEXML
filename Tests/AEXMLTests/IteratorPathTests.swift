//
//  Test 2.swift
//  AEXML
//
//  Created by Jason Jobe on 3/3/25.
//

import Testing
//import XCTest
@testable import AEXML

struct Test_2 {

    @Test func testXMLIterator() throws {
        // Example XML
        let xmlString = """
        <catalog>
            <book id="bk101">
                <title>XML Developer's Guide</title>
                <author>John Doe</author>
            </book>
            <book id="bk102">
                <title>Learning Swift</title>
                <author>Jane Smith</author>
            </book>
        </catalog>
        """

        func id(_ n: AEXMLElement) -> String {
            n["id"].string
        }
        func pr(_ n: AEXMLElement) {
            print(n.name, id(n), n.stringValue)
        }
        
        // Parse XML
        guard let xmlData = xmlString.data(using: .utf8),
           let xmlDoc = try? AEXMLDocument(xml: xmlData)
        else { return }
        
        print(xmlDoc.xml)
        let root = xmlDoc.root

        let tests = try [
            "/catalog/book[1]", "catalog/book",
            "book",
            "/book", "bad/book",
        ].compactMap(XMLSelector.parse(_:))
        
        for node in XMLIterator(root) {
            let xp = node.selectors
            for test in tests {
                if node.matches(selectors: test) {
                    print("MATCH:", test, xp)
                } else {
                    print("NO MATCH:", node.xpath)
                }
            }
//            if !node.string.isEmpty {
//                print ("  ", "'\(node.string)'")
//            }
        }
        print("done")
    }
    
    @Test func testXpath() {
        do {
            let list: [XMLSelector] = try XMLSelector.parse("path/to/element[1]/another[2]")
            print(list)
        } catch {
            print("Failed to parse XML selectors: \(error)")
        }
    }
}

extension AEXMLElement {
    func matches(selector: XMLSelector) -> Bool {
        if selector.path != self.name {
            return false
        }
        if let ndx = selector.index, ndx != self.index {
            return false
        }
        return true
    }
    
    func matches(selectors: [XMLSelector]) -> Bool {
        guard let last = selectors.last, last == self.selector {

        }
//        let me = selectors
//        for (lhs, rhs) in zip(me, selectors).reversed() {
//            if lhs.path != rhs.path {
//                return false
//            }
//            if let lhsIndex = lhs.index, let rhsIndex = rhs.index {
//                if lhsIndex != rhsIndex {
//                    return false
//                }
//            }
//        }
//        return true
    }
}

public struct XMLNode {
    public var xpath: String
    public var attributes: [String: String] = [:]
    public var children: [XMLNode] = []
    
    public func select(xpath: String) throws -> [XMLNode] {
        let selectors = try XMLSelector.parse(xpath)
        return select(selectors: selectors)
    }
    
    private func select(selectors: [XMLSelector]) -> [XMLNode] {
        guard !selectors.isEmpty else {
            return [self]
        }
        
        let firstSelector = selectors.first!
        let remainingSelectors = Array(selectors.dropFirst())
        
        if firstSelector.index == nil {
            // General selection
            let matchingChildren = children.filter { $0.xpath == firstSelector.path }
            return matchingChildren.flatMap { $0.select(selectors: remainingSelectors) }
        } else {
            // Index-based selection
            guard let child = children[safe: firstSelector.index! - 1] else {
                return []
            }
            return child.select(selectors: remainingSelectors)
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
