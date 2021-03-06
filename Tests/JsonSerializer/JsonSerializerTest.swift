//
//  JsonSerializerTest.swift
//  DataMapper
//
//  Created by Filip Dolnik on 19.01.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Quick
import Nimble
import DataMapper

class JsonSerializerTest: QuickSpec {
    
    override func spec() {
        describe("JsonSerializer") {
            let type: SupportedType = .dictionary([
                    "int": number(2),
                    "double": .double(1.1),
                    "bool": number(1),
                    "text": .string("A"),
                    "null": .null,
                    "array": .array([number(0), number(1), number(2), .null]),
                    "dictionary": .dictionary(["null": .null, "text": .string("B")])
                ])
            
            describe("typed serialize and deserialize") {
                it("serializes and deserializes to the same type") {
                    self.typedSerializeTest(for: .null)
                    self.typedSerializeTest(for: .string("a"))
                    self.typedSerializeTest(for: self.number(1))
                    self.typedSerializeTest(for: .array([.null]))
                    self.typedSerializeTest(for: .dictionary(["a": .null]))
                    self.typedSerializeTest(for: type)
                }
            }
            describe("serialize and deserialize") {
                it("serializes and deserializes to the same type") {
                    self.serializeTest(for: .null)
                    self.serializeTest(for: .string("a"))
                    self.serializeTest(for: self.number(1))
                    self.serializeTest(for: .array([.null]))
                    self.serializeTest(for: .dictionary(["a": .null]))
                    self.serializeTest(for: type)
                }
            }
        }
    }
    
    private func serializeTest(for type: SupportedType, file: String = #file, line: UInt = #line) {
        let serializer = JsonSerializer()
        
        let data = serializer.serialize(type)
        let actualType = serializer.deserialize(data)
        
        expect(actualType, file: file, line: line) == type
    }
    
    private func typedSerializeTest(for type: SupportedType, file: String = #file, line: UInt = #line) {
        let serializer = JsonSerializer()
        
        let data = serializer.typedSerialize(type)
        let actualType = serializer.typedDeserialize(data)
        
        expect(actualType, file: file, line: line) == type
    }
    
    private func number(_ value: Int) -> SupportedType {
        return .number(value == 0 || value == 1 ? SupportedNumber(bool: value == 1, int: value, double: Double(value)) :
            SupportedNumber(int: value, double: Double(value)))
    }
}
