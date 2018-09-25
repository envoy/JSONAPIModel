# JSONAPIModel

[![CircleCI](https://circleci.com/gh/envoy/JSONAPIModel.svg?style=svg)](https://circleci.com/gh/envoy/JSONAPIModel)

Simple JSONAPI parser / serializer and data store

## Overview

JSONAPIModel is a simple JSONAPI parser / serializer and data store written in Swift. We built it from ground up in house to meet Envoy's needs for iOS projects. By the time when we were trying to build this project, we looked at the community first, see if there's anything available already. However, we didn't find anything that suits our needs. JSONAPI is a pretty powerful API schema, it allows you to load objects in relationship of another object on demand. Usually the implementations we found provide advance features for JSONAPI, and we don't want that. What we want is pretty simple parser and it stores data into simple Swift data struct, ideally the model should be like this

```Swift
class DeviceConfig {
    var id: String
    var userEmail: String
    var buttonColor: String
    // ...
}
```

In the end, as nothing we found available, we decided to build our own, with few design goals in mind

 - Do not expose any JSON API relative features to the end-user of data model
 - It should be robust
 - Easy to use

If you expect this project to act as a full feature JSONAPI data model library, you're looking at wrong place.

## Example

Like we said in our design goal, we want to expose as little about JSONAPI as possible, so by design, to create a model object for JSONAPIModel, is pretty easy. Just create a class inherits from `NSObject`, and make all properties decorated with `@objc`

```Swift
import Foundation

@objcMembers final class Location: NSObject {
    /// ID of location
    let id: String

    /// Name of location
    var name: String!

    /// Employees in this location
    var employees: [Employee]

    init(id: String) {
        self.id = id
        super.init()
    }
}
```

Also, please notice that, you need to provide a constructor with `init(id: String)` signature. And all the properties other than id should all have their own default, which means you can create a JSONAPIModel object with only `id` argument

```
Location(id: "loc-12345")
```

Next, you extend the model class with `JSONAPIModelType`

```
Swift
// MARK: JSONAPIModelType
extension Location: JSONAPIModelType {
    func mapping(_ map: JSONAPIMap) throws {
        try name <- map.attribute("name")
    }

    static var metadata: JSONAPIMetadata {
        let helper = MetadataHelper<Location>(type: "locations")
        helper.hasMany("employees", { $0.employees }, { $0.employees = $1 })
        return helper.metadata
    }
}
```

In `mapping(_ map: JSONAPIMap)` function, you can bind attributes with `<-` infix operator like this

```Swift
try name <- map.attribute("name")
```

And for relationships and the JSON API model `type`, you need to define `static var metadata: JSONAPIMetadata` like this

```Swift
static var metadata: JSONAPIMetadata {
    let helper = MetadataHelper<Location>(type: "locations")
    helper.hasMany("employees", { $0.employees }, { $0.employees = $1 })
    return helper.metadata
}
```

You can use `helper.hasMany` or `helper.hasOne` for one-to-many and one-to-one relationship. The first argument is the key in `relationships` dictionary. The second argument is the getter for getting employees value. The third argument is the setter for assigning value to employees property (an array of Employee will be given as `$1` in our example).


## Todos

### Better parsing error report

For now parsing error is not helpful at all. It could simply return a `nil`, or throw an exception. It's not handled pretty well. We should provide better parsing error report, so that we may can write these error to logs file to help troubleshooting.

### Better error tolerance for invalid values

Sometimes a `nil` value returned by the backend could make the parsing fail altogether. This could bring downtime to our customers if the backend is not working as expected. Although it's really hard to keep everything up and running when the given data is bad, at least maybe we can log warning message instead of crashing the app for some more common cases like nil value or missing key.
 
