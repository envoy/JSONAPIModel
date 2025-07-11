//
//  Person.swift
//  JSONAPIModel-iOS
//
//  Created by AI Assistant on 7/10/25.
//  Copyright © 2025 Envoy Inc. All rights reserved.
//

import Foundation

import JSONAPIModel

@objcMembers final class Person: NSObject {
    let id: String
    var firstName: String!
    var lastName: String!
    var twitter: String!

    init(id: String) {
        self.id = id
        super.init()
    }
}

// MARK: JSONAPIModelType
extension Person: JSONAPIModelType {
    func mapping(_ map: JSONAPIMap) throws {
        try firstName   <- map.attribute("firstName")
        try lastName    <- map.attribute("lastName")
        try twitter     <- map.attribute("twitter")
    }

    static var metadata: JSONAPIMetadata {
        let helper = MetadataHelper<Person>(type: "people")
        return helper.metadata
    }
}