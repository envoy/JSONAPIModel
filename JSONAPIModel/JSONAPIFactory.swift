//
//  JSONAPIFactory.swift
//  Envoy
//
//  Created by Fang-Pen Lin on 11/2/16.
//  Copyright © 2016 Envoy Inc. All rights reserved.
//

import Foundation

import SwiftyJSON

/// Factory for making JSON API models
public final class JSONAPIFactory {
    private var models: [String: JSONAPIModelType.Type] = [:]
    
    public init() {
    }

    /// Register a model type to `self` factory
    ///  - Parameters modelType: type of model to register
    public func register(modelType: JSONAPIModelType.Type) {
        let metadata = modelType.metadata
        if models[metadata.type] != nil {
            fatalError("Model \(metadata.type) already registered")
        }
        models[metadata.type] = modelType
    }

    /// Create JSON API model
    ///  - Parameters id: id of model to create
    ///  - Parameters type: type of model to create
    ///  - Returns: created JSON API model, if the type does not exist, nil will be returned
    public func createModel(id: String, type: String) -> JSONAPIModelType? {
        guard let modelType = models[type] else {
            return nil
        }
        return modelType.init(id: id)
    }

    /// Create JSON API model from given JSON payload, different from creaeting model with just
    /// id and type, this method also loads attributes and relationships for you.
    ///  - Parameters id: id of model to create
    ///  - Parameters type: type of model to create
    ///  - Returns: created JSON API model, if the type does not exist, nil will be returned
    public func createModel(_ json: JSON) throws -> JSONAPIModelType? {
        guard let id = json["id"].string, let modelType = json["type"].string else {
            return nil
        }
        guard let model = createModel(id: id, type: modelType) else {
            return nil
        }
        try model.loadAttributes(json)
        model.loadRelationships(self, json: json)
        return model
    }
}
