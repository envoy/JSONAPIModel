//
//  JSONAPIModelTests.swift
//  JSONAPIModelTests
//
//  Created by Fang-Pen Lin on 9/25/18.
//  Copyright © 2018 Envoy Inc. All rights reserved.
//

import XCTest

import JSONAPIModel
import SwiftyJSON

class JSONAPIModelTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func readJSON(fileName: String) -> JSON {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: fileName, ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        return JSON(try! JSONSerialization.jsonObject(
            with: data,
            options: .allowFragments
        ))
    }

    func testLoadJSONAPIPayloadCase0() {
        let factory = JSONAPIFactory.defaultFactory
        let json = readJSON(fileName: "case0")
        do {
            let jsonModel = try factory.createModel(json["data"])
            guard let model = jsonModel as? ClassRoom else {
                XCTFail()
                return
            }
            XCTAssert(type(of: model) === ClassRoom.self)
            XCTAssertEqual(model.name, "Class Room 202")
            XCTAssertEqual(model.students.count, 0)
        } catch {
            XCTFail()
        }
    }
}
