import Foundation
import SwiftyJSON

/// JSONAPIMap provides `attribute` mapping methods for `JSONAPIModelType.mapping` method to define
/// attribute binding
public final class JSONAPIMap {
    public static let attributesKey = "attributes"

    public enum Error: Swift.Error {
        case keyError(key: String)
        case valueError(key: String)
    }

    /// Collected attributes for reading mode
    public private(set) var collectedAttributes: [String: Any]?

    private let json: JSON

    public init(data: Data, options: JSONSerialization.ReadingOptions = []) throws {
        self.json = try JSON(data: data, options: options)
    }

    internal init(_ json: JSON) {
        self.json = json
        collectedAttributes = nil
    }

    public init() {
        json = JSON([])
        collectedAttributes = [:]
    }

    /// Define attribute binding
    ///  - Parameters key: the key in `attributes` JSON dict for binding value from
    ///  - Returns: an Attribute object for the attribute binding
    public func attribute(_ key: String) -> Attribute {
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
    public func attribute<TransformType: Transform>(
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
