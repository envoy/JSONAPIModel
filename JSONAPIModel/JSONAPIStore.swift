//
//  JSONAPIStore.swift
//  Envoy
//
//  Created by Fang-Pen Lin on 10/5/16.
//  Copyright © 2016 Envoy Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Storage for JSONAPI "included" records
@objc
public final class JSONAPIStore: NSObject, Collection {
  public typealias Storage = [String: JSON]
  public typealias Index = Storage.Index
  public typealias Element = Storage.Element
  public typealias Indeces = Storage.Indices

    fileprivate let models: Storage

    fileprivate static func mappingKey(type: String, id: String) -> String {
        return "\(type)-\(id)"
    }

    public init(includedRecords: JSON) {
        var models = [String: JSON]()
        for (_, json) in includedRecords {
            guard let
                type = json["type"].string,
                let id = json["id"].string
                else {
                    continue
            }
            let key = JSONAPIStore.mappingKey(type: type, id: id)
            models[key] = json
        }
        self.models = models
        super.init()
    }

  public var startIndex: Storage.Index {
    models.startIndex
  }

  public var endIndex: Storage.Index {
    models.endIndex
  }

  public var indices: Storage.Indices {
    models.indices
  }

  public subscript(position: Storage.Index) -> Storage.Element {
    models[position]
  }

  public func index(after i: Storage.Index) -> Storage.Index {
    models.index(after: i)
  }

    /// Get model json for given type and id
    ///  - Parameters type: type of model
    ///  - Parameters id: id of model
    ///  - Returns: model for given type and id, if no model found in the store, nil will be returned
    public func get(type: String, id: String) -> JSON? {
        return models[JSONAPIStore.mappingKey(type: type, id: id)]
    }
}
