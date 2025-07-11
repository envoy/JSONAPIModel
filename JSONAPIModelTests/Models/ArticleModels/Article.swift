//
//  Article.swift
//  JSONAPIModel-iOS
//
//  Created by AI Assistant on 7/10/25.
//  Copyright © 2025 Envoy Inc. All rights reserved.
//

import Foundation

import JSONAPIModel

@objcMembers final class Article: NSObject {
    let id: String
    var title: String!

    var author: Person?
    var comments: [Comment] = []

    init(id: String) {
        self.id = id
        super.init()
    }
}

// MARK: JSONAPIModelType
extension Article: JSONAPIModelType {
    func mapping(_ map: JSONAPIMap) throws {
        try title <- map.attribute("title")
    }

    static var metadata: JSONAPIMetadata {
        let helper = MetadataHelper<Article>(type: "articles")
        helper.hasOne("author", { $0.author }, { $0.author = $1 })
        helper.hasMany("comments", { $0.comments }, { $0.comments = $1 })
        return helper.metadata
    }
}