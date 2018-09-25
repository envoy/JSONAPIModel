//
//  Class.swift
//  JSONAPIModel-iOS
//
//  Created by Fang-Pen Lin on 9/25/18.
//  Copyright © 2018 Envoy Inc. All rights reserved.
//

import Foundation

import JSONAPIModel

@objcMembers final class Book: NSObject {
    let id: String
    var name: String!
    var isbn: String!
    
    init(id: String) {
        self.id = id
        super.init()
    }
}

// MARK: JSONAPIModelType
extension Book: JSONAPIModelType {
    func mapping(_ map: JSONAPIMap) throws {
        try name        <- map.attribute("name")
        try isbn        <- map.attribute("isbn")
    }
    
    static var metadata: JSONAPIMetadata {
        let helper = MetadataHelper<Book>(type: "books")
        return helper.metadata
    }
}

