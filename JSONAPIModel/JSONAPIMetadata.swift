//
//  JSONAPIMetadata.swift
//  Envoy
//
//  Created by Fang-Pen Lin on 11/2/16.
//  Copyright © 2016 Envoy Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Metadata for JSON API model
public final class JSONAPIMetadata {
    public enum RelationshipType {
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
    public struct Relationship {
        /// Key name in `relationships` of JSON API payload
        let key: String
        /// Type of relationship
        let type: RelationshipType
    }

    public let type: String
    public fileprivate(set) var relationships: [Relationship] = []

    public init(type: String) {
        self.type = type
    }

    /// Define a relationship
    ///  - Parameter relationship: relationship to add
    public func define(_ relationship: Relationship) {
        relationships.append(relationship)
    }
}

/// TransformedAttribute provides value binding between JSON with key to the left-hand-side value
/// with data transofmration
public struct TransformedAttribute<TransformType: Transform> {
    /// JSON object
    public let json: JSON
    /// Key for reading value from the JSON object
    public let key: String
    /// The transform to be applied on the value we get from JSON object
    public let transform: TransformType
    /// Callback for collecting values
    public let collectValue: ((Any?) -> Void)?

    public init(data: Data, key: String, transform: TransformType, options: JSONSerialization.ReadingOptions = []) throws {
        self.json = try JSON(data: data, options: options)
        self.key = key
        self.transform = transform
        collectValue = nil
    }

    internal init(json: JSON, key: String, transform: TransformType) {
        self.json = json
        self.key = key
        self.transform = transform
        collectValue = nil
    }

    public init(key: String, transform: TransformType, collectValue: @escaping ((Any?) -> Void)) {
        json = JSON([])
        self.key = key
        self.transform = transform
        self.collectValue = collectValue
    }

    //// Bind value between `json[keyPath]` to the left-hand-side value
    ////  - Parameters lhs: the left-hande-side value to be bound to
    public func bind<T>(_ lhs: inout T) throws {
        if collectValue != nil {
            try bindToJSON(lhs)
        } else {
            try bindFromJSON(&lhs)
        }
    }

    /// Bind value between `json[keyPath]` to the left-hand-side optional value
    ///  - Parameters lhs: the left-hande-side optional value to be bound to
    public func bind<T>(_ lhs: inout T?) throws {
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
            throw JSONAPIMap.Error.keyError(key: key)
        }
        guard let value = transform.forward(jsonValue.object) as? T else {
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

infix operator <-

public func <- <T>(lhs: inout T, rhs: Attribute) throws {
    try rhs.bind(&lhs)
}

public func <- <T>(lhs: inout T?, rhs: Attribute) throws {
    try rhs.bind(&lhs)
}

public func <- <T, TransformType: Transform>(lhs: inout T, rhs: TransformedAttribute<TransformType>) throws {
    try rhs.bind(&lhs)
}

public func <- <T, TransformType: Transform>(lhs: inout T?, rhs: TransformedAttribute<TransformType>) throws {
    try rhs.bind(&lhs)
}
