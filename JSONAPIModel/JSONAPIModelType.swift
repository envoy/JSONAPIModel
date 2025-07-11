//
//  JSONAPIModelType.swift
//  Envoy
//
//  Created by Fang-Pen Lin on 11/2/16.
//  Copyright © 2016 Envoy Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

/// JSON API model type
public protocol JSONAPIModelType {
    /// JSON API metadata for defining attributes and relationships
    static var metadata: JSONAPIMetadata { get }
    /// ID of model
    var id: String { get }
    init(id: String)
    func mapping(_ map: JSONAPIMap) throws
}

public extension JSONAPIModelType {
    /// Load attributes from given JSON payload into `self` model
    ///  - Parameters json: json payload to load
    func loadAttributes(_ json: JSON) throws {
        let map = JSONAPIMap(json: json)
        try mapping(map)
    }

    /// Load relationships from given JSON payload into `self` model
    ///  - Parameters factory: factory for creating JSON API model
    ///  - Parameters json: json payload to load
    func loadRelationships(_ factory: JSONAPIFactory, json: JSON) {
        let meta = Self.metadata
        let relationships = json["relationships"]
        for relationship in meta.relationships {
            let data = relationships[relationship.key]["data"]
            switch relationship.type {
            case .singular(_, let setter):
                guard let id = data["id"].string, let type = data["type"].string else {
                    continue
                }
                let model = factory.createModel(id: id, type: type)
                setter(self, model)
            case .multiple(_, let setter):
                var models: [JSONAPIModelType] = []
                for (_, element) in data {
                    guard let id = element["id"].string, let type = element["type"].string else {
                        continue
                    }
                    guard let model = factory.createModel(id: id, type: type) else {
                        continue
                    }
                    models.append(model)
                }
                setter(self, models)
            }
        }
    }

    /// Load relationships from given JSON API store
    ///  - Parameters factory: factory for creating JSON API model
    ///  - Parameters store: JSON API store that contains included payload
    func loadIncluded(_ factory: JSONAPIFactory, store: JSONAPIStore) throws {
        let meta = Self.metadata
        // load attributtes and relationships from the data we found in store
        if let json = store.get(type: meta.type, id: id) {
            try loadAttributes(json)
            loadRelationships(factory, json: json)
        }

        for relationship in meta.relationships {
            switch relationship.type {
            case .singular(let getter, let setter):
                guard let model = getter(self) else {
                    continue
                }
                let modelMeta = type(of: model).metadata
                guard let modelJSON = store.get(type: modelMeta.type, id: model.id) else {
                    setter(self, nil)
                    continue
                }
                guard let newModel = try factory.createModel(modelJSON) else {
                    setter(self, nil)
                    continue
                }
                try newModel.loadIncluded(factory, store: store)
                setter(self, newModel)
            case .multiple(let getter, let setter):
                let models = getter(self)
                var newModels: [JSONAPIModelType] = []
                for model in models {
                    let modelMeta = type(of: model).metadata
                    guard let modelJSON = store.get(type: modelMeta.type, id: model.id) else {
                        // looks like we cannot find json in store, just add the old one
                        newModels.append(model)
                        try model.loadIncluded(factory, store: store)
                        continue
                    }
                    // try to create the model again from the included payload
                    guard let newModel = try factory.createModel(modelJSON) else {
                        continue
                    }
                    try newModel.loadIncluded(factory, store: store)
                    newModels.append(newModel)
                }
                setter(self, newModels)
            }
        }
    }

    /// Load relationships from given JSON API store using iterative approach (safer than recursive)
    ///  - Parameters factory: factory for creating JSON API model
    ///  - Parameters store: JSON API store that contains included payload
    func loadIncludedIterative(_ factory: JSONAPIFactory, store: JSONAPIStore) throws {
        // Use a queue to process models iteratively instead of recursively
        var processingQueue: [JSONAPIModelType] = [self]
        var processedModels: Set<String> = []

        while !processingQueue.isEmpty {
            let currentModel = processingQueue.removeFirst()
            let currentMeta = type(of: currentModel).metadata
            let modelKey = "\(currentMeta.type):\(currentModel.id)"

            // Skip if already processed to avoid infinite loops
            if processedModels.contains(modelKey) {
                continue
            }
            processedModels.insert(modelKey)

            // Load attributes and relationships from the data we found in store
            if let json = store.get(type: currentMeta.type, id: currentModel.id) {
                try currentModel.loadAttributes(json)
                currentModel.loadRelationships(factory, json: json)
            }

            // Process relationships and add related models to queue
            for relationship in currentMeta.relationships {
                switch relationship.type {
                case .singular(let getter, let setter):
                    guard let model = getter(currentModel) else {
                        continue
                    }
                    let modelMeta = type(of: model).metadata
                    guard let modelJSON = store.get(type: modelMeta.type, id: model.id) else {
                        setter(currentModel, nil)
                        continue
                    }
                    guard let newModel = try factory.createModel(modelJSON) else {
                        setter(currentModel, nil)
                        continue
                    }

                    // Add to processing queue instead of recursive call
                    processingQueue.append(newModel)
                    setter(currentModel, newModel)

                case .multiple(let getter, let setter):
                    let models = getter(currentModel)
                    var newModels: [JSONAPIModelType] = []
                    for model in models {
                        let modelMeta = type(of: model).metadata
                        guard let modelJSON = store.get(type: modelMeta.type, id: model.id) else {
                            // looks like we cannot find json in store, just add the old one
                            newModels.append(model)
                            // Add to processing queue instead of recursive call
                            processingQueue.append(model)
                            continue
                        }
                        // try to create the model again from the included payload
                        guard let newModel = try factory.createModel(modelJSON) else {
                            continue
                        }

                        // Add to processing queue instead of recursive call
                        processingQueue.append(newModel)
                        newModels.append(newModel)
                    }
                    setter(currentModel, newModels)
                }
            }
        }
    }
}
