# JSONAPIModel

[![CircleCI](https://circleci.com/gh/envoy/JSONAPIModel.svg?style=svg)](https://circleci.com/gh/envoy/JSONAPIModel)

Simple JSONAPI parser / serializer and data store

## Overview

JSONAPIModel is a simple JSONAPI parser / serializer and data store written in Swift. We built it from ground up in house to meet Envoy's needs for iOS projects. By the time when we were trying to build this project, we looked at the community first, see if there's anything available already. However, we didn't find anything that suits our needs. JSONAPI is a pretty powerful API schema, it allows you to load objects in relationship of another object. Usually the implementations we found provide advance features for JSONAPI, and we don't want that. What we want is pretty simple parser and it stores data into simple Swift data struct, ideally the model should be like this

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

TODO

