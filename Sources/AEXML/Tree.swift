//
//  Tree.swift
//
//  Created by Jason Jobe on 01/23/2025
//

import Foundation

@dynamicMemberLookup
public final class Tree {
    public typealias Value = String
    public var name: String
    public var parent: Tree?
    public var value: Value?
    
    ///  Index in parent's children array
    public var index: Int
    public private(set) var children: [Tree]
    public var slots: Slots?
    
    /// Depth in the Tree, Zero being the root
    public var depth: Int { 0 + (parent?.depth ?? 0) }
    public var count: Int {
        1 + children.reduce(0) { $0 + $1.count }
    }

    public init(name: String, _ value: Value? = nil, slots: Slots? = nil) {
        self.name = name
        self.value = value
        self.index = 0
        self.slots = slots
        children = []
    }

    public init(name: String, _ value: Value? = nil, slots: Slots? = nil, children: [Tree]) {
        self.name = name
        self.value = value
        self.index = 0
        self.slots = slots
        self.children = children
        children.enumerated().forEach { index, child in
            child.index = index
        }
    }

    public subscript<M>(dynamicMember keyPath: KeyPath<Value, M>) -> M? {
        value?[keyPath: keyPath]
    }
    
    public func add(child: Tree) {
        child.index = children.count
        children.append(child)
    }
}

extension Tree: Equatable {
    public static func ==(lhs: Tree, rhs: Tree) -> Bool {
        lhs.value == rhs.value && lhs.children == rhs.children
    }
}

extension Tree: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(children)
    }
}

extension Tree: CustomStringConvertible {
    public var description: String {
        let indent = String(repeating: " ", count: depth)
        var result = "\(indent)\(depth)"
        
        if !children.isEmpty {
            print(to: &result)
        }
        for child in children {
            print(child.description, to: &result)
//            result += "\n" + child.description
        }
        
        return result
    }
}

//extension Tree: Codable where Value: Codable { }

public extension Tree {
    func find(_ value: Value) -> Tree? {
        if self.value == value {
            return self
        }

        for child in children {
            if let match = child.find(value) {
                return match
            }
        }

        return nil
    }
}

//@resultBuilder
//struct TreeBuilder {
//    static func buildBlock<Value>(_ children: Tree<Value>...) -> [Tree<Value>] {
//        children
//    }
//}

extension Tree: Sequence {
    
    public func makeIterator() -> Iterator {
         return Iterator(self)
    }
    
    public struct Iterator: IteratorProtocol, Sequence {
        public typealias Element = Tree
        private var queue: [Element]
        private var skip: ((Element) -> Bool)?
        
        public init(_ parent: Element, skip: ((Element) -> Bool)? = nil) {
            queue = parent.children
            self.skip = skip
        }
        
        public init(_ nodes: [Element], skip: ((Element) -> Bool)? = nil) {
            queue = nodes
            self.skip = skip
        }
        
        mutating func enqueue(_ nodes: [Element]?) {
            guard let nodes else { return }
            if let skip {
                queue.append(contentsOf: nodes.filter(skip))
            } else {
                queue.append(contentsOf: nodes)
            }
        }

        public mutating func next() -> Element? {
            guard !queue.isEmpty else { return nil }
            
            let node = queue.removeFirst()
            enqueue(node.children)
            return node
        }
    }
}

extension Tree {
    internal class Parser: NSObject, XMLParserDelegate {
        
        // MARK: - Properties
        
        let document: Tree
        let data: Data

        var stack: [Tree] = []
        var top: Tree { stack.last ?? document }
        var currentElement: Tree? { stack.last }
        var currentValue: String?
        var shouldTrimWhitespace = true
        var parseError: Error?

//        private lazy var parserSettings: AEXMLOptions.ParserSettings = {
//            return document.options.parserSettings
//        }()
        
        // MARK: - Lifecycle
        
        init(document: Tree, data: Data) {
            self.document = document
            self.data = data
            super.init()
        }
        
        // MARK: - API
        
        func parse() throws {
            let parser = XMLParser(data: data)
            parser.delegate = self

//            parser.shouldProcessNamespaces = parserSettings.shouldProcessNamespaces
//            parser.shouldReportNamespacePrefixes = parserSettings.shouldReportNamespacePrefixes
//            parser.shouldResolveExternalEntities = parserSettings.shouldResolveExternalEntities
            
            let success = parser.parse()
            
            if !success {
                guard let error = parseError else { throw AEXMLError.parsingFailed }
                throw error
            }
        }
        
        // MARK: - XMLParserDelegate
        
        func parser(_ parser: XMLParser,
                    didStartElement elementName: String,
                    namespaceURI: String?,
                    qualifiedName qName: String?,
                    attributes attributeDict: [String : String]) {

            // PUSH
            let slots = attributeDict.map { key, value in
                Slot(noun: key, adjectives: [], value: value)
            }
            let it = Tree(name: elementName, slots: slots)
            top.add(child: it)
            stack.append(it)
            currentValue = nil
        }
        
        func parser(_ parser: XMLParser, foundCharacters string: String) {
            currentValue = if let currentValue {
                currentValue.appending(string)
            } else {
                string
            }
        }
        
        func parser(_ parser: XMLParser,
                    didEndElement elementName: String,
                    namespaceURI: String?,
                    qualifiedName qName: String?) {

            currentElement?.value = shouldTrimWhitespace
            ? currentValue?.trimmingCharacters(in: .whitespacesAndNewlines)
            : currentValue
            // POP
            _ = stack.popLast()
        }
        
        func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
            self.parseError = parseError
        }
        
    }

}
