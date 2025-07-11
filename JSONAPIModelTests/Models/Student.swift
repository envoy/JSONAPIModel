//
//  Student.swift
//  JSONAPIModel-iOS
//
//  Created by Fang-Pen Lin on 9/25/18.
//  Copyright © 2018 Envoy Inc. All rights reserved.
//

import Foundation

import JSONAPIModel

@objcMembers final class Student: NSObject {
    let id: String
    var name: String!
    var score: Int!

    var books: [Book] = []

    init(id: String) {
        self.id = id
        super.init()
    }
}

// MARK: JSONAPIModelType
extension Student: JSONAPIModelType {
    func mapping(_ map: JSONAPIMap) throws {
        try name        <- map.attribute("name")
        try score       <- map.attribute("score")
    }

    static var metadata: JSONAPIMetadata {
        let helper = MetadataHelper<Student>(type: "students")
        helper.hasMany("books", { $0.books }, { $0.books = $1 })
        return helper.metadata
    }
}

class Foobar {}
