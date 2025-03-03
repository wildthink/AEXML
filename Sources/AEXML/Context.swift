//
//  Context.swift
//  AEXML
//
//  Created by Jason Jobe on 2/23/25.
//

import Foundation

protocol Noun {
    var semanticType: NounType { get }
}


enum NounType { case person, place, common, proper, collective }

public typealias Adjective = String
public typealias Slots = [Slot]

public struct Slot {
    var noun: String // subject, collective noun, type/kind / proper noun -> name
    var adjectives: [Adjective]
    var value: Any?
}

public extension Slots {
    func callAsFunction(_ noun: String) -> [Slot] {
        filter({ $0.noun == noun })
    }
    
    func callAsFunction<T>(_ vt: T.Type) -> [T] {
        compactMap({ $0 as? T })
    }
}

extension AEXMLDocument {
    override var xpath: String { "" }
}

extension AEXMLElement {
    @objc var xpath: String {
        let p = parent?.xpath ?? ""
        return if hasTwin {
            "\(p)/\(name)[\(self.index)]"
        } else {
            "\(p)/\(name)"
        }
    }
}

public extension AEXMLElement {
    
    var depth: Int {
        parent?.depth ?? 0 + 1
    }
    
    var index: Int {
        1 + (parent?.children.firstIndex(of: self) ?? 0)
    }
    
    var hasTwin: Bool {
        let sib = parent?.children.firstIndex(where: { $0.name == name && $0 !== self })
        return sib != nil
    }

    var hasSiblings: Bool {
        parent?.children.count ?? 0 > 1
    }
}

extension AEXMLElement: Equatable, Identifiable {
    public var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }
    
    public static func == (lhs: AEXMLElement, rhs: AEXMLElement) -> Bool {
        lhs.id == rhs.id
    }
}

/**
 The key difference between classifiers and adjectives lies in their function and how they interact with nouns in a language.

 Classifier vs. Adjective

 1. Classifier
     •    A classifier is a grammatical marker that categorizes a noun, often based on shape, size, function, or inherent properties.
     •    Common in languages like Chinese, Thai, and Japanese (e.g., measure words in English).
     •    Usually appears with numerals or determiners (e.g., “three pieces of paper” or “a head of cattle”).
     •    Example in Mandarin Chinese:
     •    一只猫 (yī zhī māo) → “one CLF cat” (只 zhī is the classifier for small animals)

 2. Adjective
     •    An adjective describes a property or attribute of a noun (e.g., color, size, shape, quality).
     •    In languages like English, adjectives typically come before a noun (“a red apple”), while in others, they follow the noun (e.g., Spanish: manzana roja).
     •    Example in English:
     •    “The tall tree” (tall = adjective modifying ‘tree’)

 Key Differences

 Feature          Classifier                         Adjective
 Function         Categorizes nouns         Describes nouns
 Dependency  Usually required with numbers/determiners    Can be used freely
 Position          Appears between a numeral and noun    Precedes or follows the noun
 Languages     Found in classifier languages (e.g., Mandarin, Thai)    Found in most languages

 Example Contrast
     •    Classifier: “Three cups of tea” (classifier = cups, categorizing the noun)
     •    Adjective: “Three hot teas” (adjective = hot, describing the noun)

 In short, classifiers classify, while adjectives describe.
 */

/*
 In English, the typical order of modifiers when describing a noun is as follows:
     1.    Determiners/Articles: These are words like “a,” “an,” “the,” “this,” “that,” etc.
     x.    Ordinal: first, 2nd, ..., last previous/next
     2.    Observations or Opinions: Adjectives that describe opinions or observations, such as “beautiful,” “ugly,” “interesting,” etc.
     3.    Size: Adjectives that describe the size of the noun, such as “big,” “small,” “large,” etc.
     4.    Age: Adjectives that describe the age of the noun, such as “old,” “new,” “ancient,” etc.
     5.    Shape: Adjectives that describe the shape of the noun, such as “round,” “square,” “triangular,” etc.
     6.    Color: Adjectives that describe the color of the noun, such as “red,” “blue,” “green,” etc.
     7.    Origin: Adjectives that describe the origin of the noun, such as “American,” “French,” “Chinese,” etc.
     8.    Material: Adjectives that describe the material of the noun, such as “wooden,” “metallic,” “plastic,” etc.
     9.    Qualifier: Any final adjectives or phrases that further qualify the noun, such as “for children,” “for sale,” “in the box,” etc.

 For example, consider the phrase “a beautiful old round wooden table.” It follows the order: determiner (“a”), observation (“beautiful”), age (“old”), shape (“round”), material (“wooden”), and finally the noun (“table”).
 */
