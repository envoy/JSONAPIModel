//
//  Comment.swift
//  JSONAPIModel-iOS
//
//  Created by AI Assistant on 7/10/25.
//  Copyright © 2025 Envoy Inc. All rights reserved.
//

import Foundation

import JSONAPIModel

@objcMembers final class Comment: NSObject {
    let id: String
    var body: String!

    var author: Person?

    init(id: String) {
        self.id = id
        super.init()
    }
}

// MARK: JSONAPIModelType
extension Comment: JSONAPIModelType {
    func mapping(_ map: JSONAPIMap) throws {
        try body <- map.attribute("body")
    }

    static var metadata: JSONAPIMetadata {
        let helper = MetadataHelper<Comment>(type: "comments")
        helper.hasOne("author", { $0.author }, { $0.author = $1 })
        return helper.metadata
    }
}