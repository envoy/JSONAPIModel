//
//  Class.swift
//  JSONAPIModel-iOS
//
//  Created by Fang-Pen Lin on 9/25/18.
//  Copyright © 2018 Envoy Inc. All rights reserved.
//

import Foundation

import JSONAPIModel

@objcMembers final class ClassRoom: NSObject {
    let id: String
    var name: String!

    var students: [Student] = []

    init(id: String) {
        self.id = id
        super.init()
    }
}

// MARK: JSONAPIModelType
extension ClassRoom: JSONAPIModelType {
    func mapping(_ map: JSONAPIMap) throws {
        try name        <- map.attribute("name")
    }

    static var metadata: JSONAPIMetadata {
        let helper = MetadataHelper<ClassRoom>(type: "class-rooms")
        helper.hasMany("students", { $0.students }, { $0.students = $1 })
        return helper.metadata
    }
}

