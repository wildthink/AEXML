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

    @Test func testXMLIterator() {
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

        let tests = [
            "/catalog/book", "catalog/book",
            "book",
            "/book", "bad/book",
        ]
        
        for node in XMLIterator(root) {
            print(node.xpath)
            if !node.string.isEmpty {
                print ("  ", "'\(node.string)'")
            }
        }
        print("done")
    }
    
}
