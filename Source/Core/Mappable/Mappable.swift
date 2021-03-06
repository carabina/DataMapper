//
//  Mappable.swift
//  DataMapper
//
//  Created by Filip Dolnik on 21.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public typealias SerializableAndDeserializable = Serializable & Deserializable

public protocol Mappable: SerializableAndDeserializable {
    
    mutating func mapping(_ data: inout MappableData) throws
}

extension Mappable {
    
    public func serialize(to data: inout SerializableData) {
        mapping(&data)
    }
}

extension Mappable {
    
    public mutating func mapping(_ data: DeserializableData) throws {
        var wrapper: MappableData = DeserializableMappableDataWrapper(delegate: data)
        try mapping(&wrapper)
    }
    
    public func mapping(_ data: inout SerializableData) {
        do {
            var wrapper: MappableData = SerializableMappableDataWrapper(delegate: data)
            var s = self
            try s.mapping(&wrapper)
            if let wrapper = wrapper as? SerializableMappableDataWrapper {
                data = wrapper.delegate
            }
        }
        catch {
            fatalError("Mapping called for serialization cannot throw exception.")
        }
    }
}

// Mutating function from extension cannot be called on Class instance.
extension Mappable where Self: AnyObject {
    
    public func mapping(_ data: DeserializableData) throws {
        var wrapper: MappableData = DeserializableMappableDataWrapper(delegate: data)
        var s = self
        try s.mapping(&wrapper)
    }
}
