/**
 *  https://github.com/tadija/AEXML
 *  Copyright © Marko Tadić 2014-2024
 *  Licensed under the MIT license
 */

import Foundation
#if canImport(FoundationXML)
import FoundationXML
#endif

/// Simple wrapper around `Foundation.XMLParser`.
internal class AEXMLParser: NSObject, XMLParserDelegate {
    
    // MARK: - Properties
    
    let document: AEXMLDocument
    let data: Data

    var stack: [AEXMLElement] = []
    var top: AEXMLElement { stack.last ?? document }
    var currentElement: AEXMLElement? { stack.last }
    var currentValue: String?
    
    var parseError: Error?

    private lazy var parserSettings: AEXMLOptions.ParserSettings = {
        return document.options.parserSettings
    }()
    
    // MARK: - Lifecycle
    
    init(document: AEXMLDocument, data: Data) {
        self.document = document
        self.data = data
        super.init()
    }
    
    // MARK: - API
    
    func parse() throws {
        let parser = XMLParser(data: data)
        parser.delegate = self

        parser.shouldProcessNamespaces = parserSettings.shouldProcessNamespaces
        parser.shouldReportNamespacePrefixes = parserSettings.shouldReportNamespacePrefixes
        parser.shouldResolveExternalEntities = parserSettings.shouldResolveExternalEntities
        
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
        let it = top.addChild(name: elementName, attributes: attributeDict)
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

        currentElement?.value = parserSettings.shouldTrimWhitespace
        ? currentValue?.trimmingCharacters(in: .whitespacesAndNewlines)
        : currentValue
        // POP
        _ = stack.popLast()
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseError = parseError
    }
    
}
