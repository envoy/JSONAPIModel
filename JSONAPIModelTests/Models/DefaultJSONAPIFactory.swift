//
//  DefaultJSONAPIFactory.swift
//  JSONAPIModel-iOS
//
//  Created by Fang-Pen Lin on 9/25/18.
//  Copyright © 2018 Envoy Inc. All rights reserved.
//

import Foundation

import JSONAPIModel

extension JSONAPIFactory {
    /// Default factory that registered with all models
    static var defaultFactory: JSONAPIFactory {
        let factory = JSONAPIFactory()
        factory.register(modelType: ClassRoom.self)
        factory.register(modelType: Student.self)
        factory.register(modelType: Book.self)
        return factory
    }
}
