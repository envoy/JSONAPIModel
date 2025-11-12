import Foundation
import SwiftyJSON

/// Attribute provides value binding between JSON with key to the left-hand-side value
public struct Attribute {
    /// JSON object
    public let json: JSON
    /// Key for reading value from the JSON object
    public let key: String
    /// Callback for collecting values
    public let collectValue: ((Any?) -> Void)?

    public init(data: Data, options: JSONSerialization.ReadingOptions = [], key: String) throws {
        self.json = try JSON(data: data, options: options)
        self.key = key
        collectValue = nil
    }

    public init(key: String, collectValue: @escaping ((Any?) -> Void)) {
        self.key = key
        self.collectValue = collectValue
        json = JSON([])
    }

    internal init(json: JSON, key: String) {
        self.json = json
        self.key = key
        collectValue = nil
    }
}

extension Attribute {
    //// Bind value between `json[keyPath]` to the left-hand-side value
    ////  - Parameters lhs: the left-hande-side value to be bound to
    public func bind<T>(_ lhs: inout T) throws {
        if collectValue != nil {
            try bindToJSON(lhs)
        } else {
            try bindFromJSON(&lhs)
        }
    }

    //// Bind value between `json[keyPath]` to the left-hand-side optional value
    ////  - Parameters lhs: the optional left-hande-side optional value to be bound to
    public func bind<T>(_ lhs: inout T?) throws {
        if collectValue != nil {
            try bindToJSON(lhs)
        } else {
            try bindFromJSON(&lhs)
        }
    }
}

extension Attribute {
    private func bindToJSON<T>(_ lhs: T) throws {
        collectValue!(lhs)
    }

    private func bindToJSON<T>(_ lhs: T?) throws {
        guard let value = lhs else {
            return
        }
        collectValue!(value)
    }
}

extension Attribute {
    private func bindFromJSON<T>(_ lhs: inout T) throws {
        let jsonValue = json[key]
        guard jsonValue.exists() else {
            throw JSONAPIMap.Error.keyError(key: key)
        }
        guard let value = jsonValue.object as? T else {
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
