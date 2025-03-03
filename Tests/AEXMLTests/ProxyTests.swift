//
//  Test.swift
//  AEXML
//
//  Created by Jason Jobe on 2/24/25.
//

import Testing

struct Test {

    @Test func testExpressions() async throws {
//        let op = (1 == "2")
//        print(op)
        
        let kp = \Thing.name == "foo"
        print(kp)
        print(\Thing.name == "foo")
        print(Proxy<Thing>().age == Proxy<Thing>().count)
    }

}

@dynamicMemberLookup
struct Proxy<T> {
    var type: T.Type { T.self }
    
    subscript <S>(dynamicMember keyPath: KeyPath<T, S>) -> Field<T, S> {
        .init(name: String(describing: keyPath), keypath: keyPath)
    }
}

extension Field {
    static func ==(lhs: Self, rhs: Self
    ) -> Compare<KeyPath<R,V>,KeyPath<R,V>> {
        Compare(op: "=", lhs: lhs.keypath, rhs: rhs.keypath)
    }
}

struct Field<R,V> {
    var name: String
    var keypath: KeyPath<R,V>
}

struct Thing {
    var name: String
    var age: Int
    var count: Int
}

struct Compare<L, R> {
    var op: String
    var lhs: L
    var rhs: R
}

func ==<T,V>(lhs: KeyPath<T,V>, rhs: KeyPath<T,V>
) -> Compare<KeyPath<T,V>,KeyPath<T,V>> {
    Compare(op: "=", lhs: lhs, rhs: rhs)
}

func ==<T,V>(lhs: KeyPath<T,V>, rhs: V) -> Compare<KeyPath<T,V>,V> {
    Compare(op: "=", lhs: lhs, rhs: rhs)
}

//func ==<V>(lhs: V, rhs: V) -> Compare<V,V> {
//    Compare(op: "=", lhs: lhs, rhs: rhs)
//}
//
//func <=<L,R>(lhs: L, rhs: R) -> Compare<L,R> {
//    Compare(op: "<=", lhs: lhs, rhs: rhs)
//}
