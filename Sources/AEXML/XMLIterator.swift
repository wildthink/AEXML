//
//  XMLIterator.swift
//  AEXML
//
//  Created by Jason Jobe on 3/3/25.
//
import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif


public struct XMLIterator: IteratorProtocol, Sequence {
    public typealias Element = AEXMLElement
    private var queue: [Element]
    private var prune: ((Element) -> Bool)?
    
    public init(_ parent: Element) {
        queue = parent.children
    }

    public init(_ nodes: [Element]) {
        queue = nodes
    }

    mutating func enqueue(_ nodes: [Element]?) {
        guard let nodes else { return }
        if let prune = prune {
            queue.append(contentsOf: nodes.filter(prune))
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

extension StringProtocol {
    
    func caseInsensitiveEqual(_ other: (any StringProtocol)?) -> Bool {
        if let other {
            caseInsensitiveCompare(other) == .orderedSame
        } else { false }
    }

    func caseInsensitiveEqual(_ other: any StringProtocol) -> Bool {
        caseInsensitiveCompare(other) == .orderedSame
    }
}

public extension Sequence where Element == AEXMLElement {
    func nodes(named name: String) -> [Element] {
        filter { name.caseInsensitiveEqual($0.name) }
    }
    
    func matching(path: String) -> [Element] {
        let list = filter { $0.matches(path: path) }
        return list
    }
}

public extension AEXMLElement {

    func foreach() -> XMLIterator {
        XMLIterator(self)
    }

    func matches(path: String) -> Bool {
        let p = path.split(separator: "/", omittingEmptySubsequences: false)
        return matches(path: p[0...])
    }
    
    func matches(path: ArraySlice<String.SubSequence>) -> Bool {
        let name = self.name
        guard let key = path.last, name.caseInsensitiveEqual(key)
        else { return false }

        let rest = path.dropLast()
        if rest.isEmpty { return true }
        // No parent but expects one => false / no match
        return parent?.matches(path: rest) ?? false
    }
}
