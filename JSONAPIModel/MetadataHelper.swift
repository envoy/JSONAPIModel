/// MetadataHelper is a helper for creating JSONAPIMetadata, it does the ugly type casting for you
/// so that you don't need to.
public struct MetadataHelper<ModelType: JSONAPIModelType> {
    public let metadata: JSONAPIMetadata
    public init(type: String) {
        metadata = JSONAPIMetadata(type: type)
    }

    /// Define a has-one relationship
    ///  - Parameters key: key of relationship
    ///  - Parameters getter: getter function for getting relationship JSONAPIModelType object from
    ///                        model
    ///  - Parameters setter: setter function for setting relationship JSONAPIModelType object to
    ///                        model
    public func hasOne<ValueType: JSONAPIModelType>(
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
    ///                        array from model
    ///  - Parameters setter: setter function for setting relationship JSONAPIModelType object
    ///                        array to model
    public func hasMany<ValueType: JSONAPIModelType>(
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
