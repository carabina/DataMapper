//
//  PolymorphDataProvider.swift
//  DataMapper
//
//  Created by Filip Dolnik on 28.10.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import Foundation

public final class PolymorphDataProvider {
    
    private var nameAndKeyOfTypeCache: [ObjectIdentifier: (name: String, key: String)] = [:]
    private var keysOfTypeCache: [ObjectIdentifier: Set<String>] = [:]
    private var castableFromTypeByNameByKeyCache: [ObjectIdentifier: [String: [String: Polymorphic.Type]]] = [:]
    
    private let syncQueue = DispatchQueue(label: "PolymorphDataProvider_syncQueue")
    
    public init() {
    }
    
    public func nameAndKey(of type: Polymorphic.Type) -> (name: String, key: String) {
        return syncQueue.sync {
            // Used also in serialization (not as a base type).
            cache(type: type, throwErrorIfPolymorphicInfoIsNotOverriden: false)
            // Value always exists.
            return nameAndKeyOfTypeCache[ObjectIdentifier(type)]!
        }
    }
    
    public func keys(of type: Polymorphic.Type) -> Set<String> {
        return syncQueue.sync {
            cache(type: type)
            // Value always exists.
            return keysOfTypeCache[ObjectIdentifier(type)]!
        }
    }
    
    public func polymorphType(of type: Polymorphic.Type, named name: String, forKey key: String) -> Polymorphic.Type? {
        return syncQueue.sync {
            cache(type: type)
            return castableFromTypeByNameByKeyCache[ObjectIdentifier(type)]?[name]?[key]
        }
    }
    
    private func cache(type: Polymorphic.Type, throwErrorIfPolymorphicInfoIsNotOverriden: Bool = true) {
        precondition(!throwErrorIfPolymorphicInfoIsNotOverriden || type.polymorphicInfo.type == type,
                     "\(type) does not override polymorphicInfo. Using it as a base polymorphic type is in most cases programming error.")
        
        if nameAndKeyOfTypeCache[ObjectIdentifier(type)] == nil {
            addToCache(type: type)
        }
    }
    
    private func addToCache(type: Polymorphic.Type) {
        let identifier = ObjectIdentifier(type)
        let polymorphicInfo = type.polymorphicInfo
        let isPolymorphicInfoOverriden = polymorphicInfo.type == type
        let name = isPolymorphicInfoOverriden ? polymorphicInfo.name : type.defaultName
        
        nameAndKeyOfTypeCache[identifier] = (name: name, key: type.polymorphicKey)
        keysOfTypeCache[identifier] = [type.polymorphicKey]
        castableFromTypeByNameByKeyCache[identifier] = [name:[type.polymorphicKey:type]]
        
        if isPolymorphicInfoOverriden {
            polymorphicInfo.registeredSubtypes.forEach { addSubtypeToCache(for: identifier, subtype: $0) }
        }
    }
    
    private func addSubtypeToCache(for typeIdentifier: ObjectIdentifier, subtype: Polymorphic.Type) {
        cache(type: subtype, throwErrorIfPolymorphicInfoIsNotOverriden: false)
        
        let subtypeIdentifier = ObjectIdentifier(subtype)
        keysOfTypeCache[typeIdentifier]?.formUnion(keysOfTypeCache[subtypeIdentifier] ?? [])
        castableFromTypeByNameByKeyCache[subtypeIdentifier]?.forEach { name, dictionary in
            dictionary.forEach { key, castableType in
                precondition(castableFromTypeByNameByKeyCache[typeIdentifier]?[name]?[key] == nil,
                             "\(castableType) and \((castableFromTypeByNameByKeyCache[typeIdentifier]?[name]?[key])!) cannot have the same key and name.")
                
                if castableFromTypeByNameByKeyCache[typeIdentifier]?[name] == nil {
                    castableFromTypeByNameByKeyCache[typeIdentifier]?[name] = [:]
                }
                castableFromTypeByNameByKeyCache[typeIdentifier]?[name]?[key] = castableType
            }
        }
    }
}
