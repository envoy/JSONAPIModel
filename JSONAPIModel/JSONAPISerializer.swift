//
//  JSONAPISerializer.swift
//  Envoy
//
//  Created by Fang-Pen Lin on 12/7/16.
//  Copyright © 2016 Envoy Inc. All rights reserved.
//

import Foundation

import SwiftyJSON

/// JSONAPISerializer serialize given JSONAPIModelType into JSON
public struct JSONAPISerializer {
    /// Serialize JSON API model into `{"data": {...}, "included": [...]}` format payload
    ///  - Parameters model: JSONAPIModelType to be serialized
    ///  - Returns: the serialized JSON API payload object
    public func serializePayload(model: JSONAPIModelType) throws -> Any {
        var included = [Any]()
        try collectInclude(model: model, included: &included)
        return [
            "data": try serializeModel(model: model),
            "included": included
        ]
    }

    /// Serialize JSON API model into `{"data": [...], "included": [...]}` format payload
    ///  - Parameters models: array of JSONAPIModelType to be serialized
    ///  - Returns: the serialized JSON API payload object
    public func serializePayload(models: [JSONAPIModelType]) throws -> Any {
        var included = [Any]()
        for model in models {
            try collectInclude(model: model, included: &included)
        }
        return [
            "data": try models.map(serializeModel),
            "included": included
        ]
    }

    /// Serialize single JSON API model
    ///  - Parameters models: JSONAPIModelType to be serialized
    ///  - Returns: the serialized JSON API object
    public func serializeModel(model: JSONAPIModelType) throws -> Any {
        let meta = type(of: model).metadata
        let map = JSONAPIMap()
        try model.mapping(map)

        var dict: [String: Any] = [
            "id": model.id,
            "type": meta.type
        ]

        if let attributes = map.collectedAttributes, attributes.count > 0 {
            dict["attributes"] = attributes
        }

        var relationships: [String: Any] = [:]
        for relationship in meta.relationships {
            guard let value = serializeRelationship(model: model, relationship: relationship) else {
                continue
            }
            relationships[relationship.key] = value
        }
        if relationships.count > 0 {
            dict["relationships"] = relationships
        }
        return dict
    }

    private func collectInclude(model: JSONAPIModelType, included: inout [Any]) throws {
        let meta = type(of: model).metadata
        for relationship in meta.relationships {
            switch relationship.type {
            case .singular(let getter, _):
                guard let childModel = getter(model) else {
                    continue
                }
                included.append(try serializeModel(model: childModel))
                try collectInclude(model: childModel, included: &included)
            case .multiple(let getter, _):
                let childModels = getter(model)
                for childModel in childModels {
                    included.append(try serializeModel(model: childModel))
                    try collectInclude(model: childModel, included: &included)
                }
            }
        }
    }

    private func serializeRelationship(
        model: JSONAPIModelType,
        relationship: JSONAPIMetadata.Relationship
    ) -> Any? {
        let result: [String: Any]
        switch relationship.type {
        case .singular(let getter, _):
            guard let childModel = getter(model) else {
                return nil
            }
            let meta = type(of: childModel).metadata
            result = [
                "data": [
                    "id": childModel.id,
                    "type": meta.type
                ]
            ]
        case .multiple(let getter, _):
            let childModels = getter(model)
            var data: [[String: Any]] = []
            for childModel in childModels {
                let meta = type(of: childModel).metadata
                data.append([
                    "id": childModel.id,
                    "type": meta.type
                    ])
            }
            result = [
                "data": data
            ]
        }
        return result
    }
}
