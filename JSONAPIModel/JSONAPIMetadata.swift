//
//  JSONAPIMetadata.swift
//  Envoy
//
//  Created by Fang-Pen Lin on 11/2/16.
//  Copyright © 2016 Envoy Inc. All rights reserved.
//

import Foundation

import CocoaLumberjack
import SwiftyJSON

/// Metadata for JSON API model
final class JSONAPIMetadata {
    enum RelationshipType {
        /// Has one relationship type
        case singular(
            getter: ((JSONAPIModelType) -> JSONAPIModelType?),
            setter: ((JSONAPIModelType, JSONAPIModelType?) -> Void)
        )
        /// Has many relationship type
        case multiple(
            getter: ((JSONAPIModelType) -> [JSONAPIModelType]),
            setter: ((JSONAPIModelType, [JSONAPIModelType]) -> Void)
        )
    }
    struct Relationship {
        /// Key name in `relationships` of JSON API payload
        let key: String
        /// Type of relationship
        let type: RelationshipType
    }

    let type: String
    fileprivate(set) var relationships: [Relationship] = []

    init(type: String) {
        self.type = type
    }

    /// Define a relationship
    ///  - Parameter relationship: relationship to add
    func define(_ relationship: Relationship) {
        relationships.append(relationship)
    }
}

/// MetadataHelper is a helper for creating JSONAPIMetadata, it does the ugly type casting for you
/// so that you don't need to.
struct MetadataHelper<ModelType: JSONAPIModelType> {
    let metadata: JSONAPIMetadata
    init(type: String) {
        metadata = JSONAPIMetadata(type: type)
    }

    /// Define a has-one relationship
    ///  - Parameters key: key of relationship
    ///  - Parameters getter: getter function for getting relationship JSONAPIModelType object from
    //                        model
    ///  - Parameters setter: setter function for setting relationship JSONAPIModelType object to
    //                        model
    func hasOne<ValueType: JSONAPIModelType>(
        _ key: String,
        _ getter: @escaping ((ModelType) -> ValueType?),
        _ setter: @escaping ((ModelType, ValueType?) -> Void)
        ) {
        let relationship = JSONAPIMetadata.Relationship(
            key: key,
            type: .singular(
                getter: { (model: JSONAPIModelType) -> JSONAPIModelType? in
                    return getter(model as! ModelType)
            },
                setter: { (model: JSONAPIModelType, value: JSONAPIModelType?) -> Void in
                    return setter(model as! ModelType, value as? ValueType)
            }
            )
        )
        metadata.define(relationship)
    }

    /// Define a has-many relationship
    ///  - Parameters key: key of relationship
    ///  - Parameters getter: getter function for getting relationship JSONAPIModelType object
    //                        array from model
    ///  - Parameters setter: setter function for setting relationship JSONAPIModelType object
    //                        array to model
    func hasMany<ValueType: JSONAPIModelType>(
        _ key: String,
        _ getter: @escaping ((ModelType) -> [ValueType]),
        _ setter: @escaping ((ModelType, [ValueType]) -> Void)
        ) {
        let relationship = JSONAPIMetadata.Relationship(
            key: key,
            type: .multiple(
                getter: { (model: JSONAPIModelType) -> [JSONAPIModelType] in
                    return getter(model as! ModelType).map { $0 as JSONAPIModelType }
            },
                setter: { (model: JSONAPIModelType, values: [JSONAPIModelType]) -> Void in
                    return setter(model as! ModelType, values.map { $0 as! ValueType })
            }
            )
        )
        metadata.define(relationship)
    }
}

/// Attribute provides value binding between JSON with key to the left-hand-side value
struct Attribute {
    /// JSON object
    let json: JSON
    /// Key for reading value from the JSON object
    let key: String
    /// Callback for collecting values
    let collectValue: ((Any?) -> Void)?

    init(json: JSON, key: String) {
        self.json = json
        self.key = key
        collectValue = nil
    }

    init(key: String, collectValue: @escaping ((Any?) -> Void)) {
        self.key = key
        self.collectValue = collectValue
        json = JSON([])
    }

    //// Bind value between `json[keyPath]` to the left-hand-side value
    ////  - Parameters lhs: the left-hande-side value to be bound to
    func bind<T>(_ lhs: inout T) throws {
        if collectValue != nil {
            try bindToJSON(lhs)
        } else {
            try bindFromJSON(&lhs)
        }
    }

    //// Bind value between `json[keyPath]` to the left-hand-side optional value
    ////  - Parameters lhs: the optional left-hande-side optional value to be bound to
    func bind<T>(_ lhs: inout T?) throws {
        if collectValue != nil {
            try bindToJSON(lhs)
        } else {
            try bindFromJSON(&lhs)
        }
    }

    private func bindToJSON<T>(_ lhs: T) throws {
        collectValue!(lhs)
    }

    private func bindToJSON<T>(_ lhs: T?) throws {
        guard let value = lhs else {
            return
        }
        collectValue!(value)
    }

    private func bindFromJSON<T>(_ lhs: inout T) throws {
        let jsonValue = json[key]
        guard jsonValue.exists() else {
            DDLogError("Failed to bind value from \(json) @ \(key), key doesn't exist")
            throw JSONAPIMap.Error.keyError(key: key)
        }
        guard let value = jsonValue.object as? T else {
            DDLogError("Failed to bind value from \(json) @ \(key), bad value type")
            throw JSONAPIMap.Error.valueError(key: key)
        }
        lhs = value
    }

    private func bindFromJSON<T>(_ lhs: inout T?) throws {
        let jsonValue = json[key]
        guard jsonValue.exists() else {
            return
        }
        guard jsonValue.null == nil else {
            lhs = nil
            return
        }
        guard let value = jsonValue.object as? T else {
            return
        }
        lhs = value
    }
}

/// TransformedAttribute provides value binding between JSON with key to the left-hand-side value
/// with data transofmration
struct TransformedAttribute<TransformType: Transform> {
    /// JSON object
    let json: JSON
    /// Key for reading value from the JSON object
    let key: String
    /// The transform to be applied on the value we get from JSON object
    let transform: TransformType
    /// Callback for collecting values
    let collectValue: ((Any?) -> Void)?

    init(json: JSON, key: String, transform: TransformType) {
        self.json = json
        self.key = key
        self.transform = transform
        collectValue = nil
    }

    init(key: String, transform: TransformType, collectValue: @escaping ((Any?) -> Void)) {
        json = JSON([])
        self.key = key
        self.transform = transform
        self.collectValue = collectValue
    }

    //// Bind value between `json[keyPath]` to the left-hand-side value
    ////  - Parameters lhs: the left-hande-side value to be bound to
    func bind<T>(_ lhs: inout T) throws {
        if collectValue != nil {
            try bindToJSON(lhs)
        } else {
            try bindFromJSON(&lhs)
        }
    }

    /// Bind value between `json[keyPath]` to the left-hand-side optional value
    ///  - Parameters lhs: the left-hande-side optional value to be bound to
    func bind<T>(_ lhs: inout T?) throws {
        if collectValue != nil {
            try bindToJSON(lhs)
        } else {
            try bindFromJSON(&lhs)
        }
    }

    private func bindToJSON<T>(_ lhs: T) throws {
        guard
            let value = lhs as? TransformType.ValueType,
            let transformed = transform.backward(value)
            else {
                DDLogError("Failed to bind value to \(key), bad value type")
                throw JSONAPIMap.Error.valueError(key: key)
        }
        collectValue!(transformed)
    }

    private func bindToJSON<T>(_ lhs: T?) throws {
        guard
            let value = lhs as? TransformType.ValueType,
            let transformed = transform.backward(value)
            else {
                return
        }
        collectValue!(transformed)
    }

    private func bindFromJSON<T>(_ lhs: inout T) throws {
        let jsonValue = json[key]
        guard jsonValue.exists() else {
            DDLogError("Failed to bind value from \(json) @ \(key), key doesn't exist")
            throw JSONAPIMap.Error.keyError(key: key)
        }
        guard let value = transform.forward(jsonValue.object) as? T else {
            DDLogError("Failed to bind value from \(json) @ \(key), bad value type")
            throw JSONAPIMap.Error.valueError(key: key)
        }
        lhs = value
    }

    private func bindFromJSON<T>(_ lhs: inout T?) throws {
        let jsonValue = json[key]
        guard jsonValue.exists() else {
            return
        }
        guard jsonValue.null == nil else {
            lhs = nil
            return
        }
        guard let value = transform.forward(jsonValue.object) as? T else {
            return
        }
        lhs = value
    }
}

/// JSONAPIMap provides `attribute` mapping methods for `JSONAPIModelType.mapping` method to define
/// attribute binding
final class JSONAPIMap {
    static let attributesKey = "attributes"
    enum Error: Swift.Error {
        case keyError(key: String)
        case valueError(key: String)
    }

    /// Collected attributes for reading mode
    private(set) var collectedAttributes: [String: Any]?

    private let json: JSON

    init(json: JSON) {
        self.json = json
    }

    init() {
        json = JSON([])
        collectedAttributes = [:]
    }

    /// Define attribute binding
    ///  - Parameters key: the key in `attributes` JSON dict for binding value from
    ///  - Returns: an Attribute object for the attribute binding
    func attribute(_ key: String) -> Attribute {
        if collectedAttributes != nil {
            return Attribute(key: key) { value in
                self.collectedAttributes![key] = value
            }
        } else {
            return Attribute(json: json[JSONAPIMap.attributesKey], key: key)
        }
    }

    /// Define attribute binding using data transformer
    ///  - Parameters key: the key in `attributes` JSON dict for binding value from
    ///  - Parameters using: the TransformType to be used for transforming binding data
    ///  - Returns: an Attribute object for the attribute binding
    func attribute<TransformType: Transform>(
        _ key: String,
        using transform: TransformType
        ) -> TransformedAttribute<TransformType> {
        if collectedAttributes != nil {
            return TransformedAttribute(
                key: key,
                transform: transform
            ) { value in
                self.collectedAttributes![key] = value
            }
        } else {
            return TransformedAttribute(
                json: json[JSONAPIMap.attributesKey],
                key: key,
                transform: transform
            )
        }
    }
}

infix operator <-

func <- <T>(lhs: inout T, rhs: Attribute) throws {
    try rhs.bind(&lhs)
}

func <- <T>(lhs: inout T?, rhs: Attribute) throws {
    try rhs.bind(&lhs)
}

func <- <T, TransformType: Transform>(lhs: inout T, rhs: TransformedAttribute<TransformType>) throws {
    try rhs.bind(&lhs)
}

func <- <T, TransformType: Transform>(lhs: inout T?, rhs: TransformedAttribute<TransformType>) throws {
    try rhs.bind(&lhs)
}
