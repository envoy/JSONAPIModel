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
        let test = Bundle.module.bundlePath
        print(test)
        let path = Bundle.module.path(forResource: fileName, ofType: "json")!
        let data = try! Data(contentsOf: URL(fileURLWithPath: path))
        return JSON(try! JSONSerialization.jsonObject(
            with: data,
            options: .allowFragments
        ))
    }

    func testLoadJSONAPIPayload() {
        let factory = JSONAPIFactory.defaultFactory
        let json = readJSON(fileName: "payload")
        do {
            let jsonModel = try factory.createModel(json["data"])
            guard let model = jsonModel as? ClassRoom else {
                XCTFail()
                return
            }
            XCTAssert(type(of: model) === ClassRoom.self)
            XCTAssertEqual(model.id, "class-room-001")
            XCTAssertEqual(model.name, "Class Room 202")
            XCTAssertEqual(model.students.count, 3)

            let store = JSONAPIStore(includedRecords: json["included"])
            try jsonModel?.loadIncluded(factory, store: store)

            let john = model.students[0]
            XCTAssertEqual(john.id, "student-001")
            XCTAssertEqual(john.name, "John")
            XCTAssertEqual(john.books.count, 2)
            let firstBook = john.books[0]
            XCTAssertEqual(firstBook.id, "book-001")
            XCTAssertEqual(firstBook.name, "Head First Python")
            XCTAssertEqual(firstBook.isbn, "978-1449382674")
            let secondBook = john.books[1]
            XCTAssertEqual(secondBook.id, "book-002")
            XCTAssertEqual(secondBook.name, "Head First Programming")
            XCTAssertEqual(secondBook.isbn, "978-0596802370")

            let marry = model.students[1]
            XCTAssertEqual(marry.id, "student-002")
            XCTAssertEqual(marry.name, "Marry")
            XCTAssertEqual(marry.books.count, 0)

            let jenny = model.students[2]
            XCTAssertEqual(jenny.id, "student-003")
            XCTAssertEqual(jenny.name, "Jenny")
            XCTAssertEqual(jenny.books.count, 1)
            let thirdBook = jenny.books[0]
            XCTAssertEqual(thirdBook.id, "book-003")
            XCTAssertEqual(thirdBook.name, "Effective Modern C++")
            XCTAssertEqual(thirdBook.isbn, "978-1491903995")
        } catch {
            XCTFail()
        }
    }


    func testLoadJSONAPIPayloadUsingIterative() {
        let factory = JSONAPIFactory.defaultFactory
        let json = readJSON(fileName: "payload")
        do {
            let jsonModel = try factory.createModel(json["data"])
            guard let model = jsonModel as? ClassRoom else {
                XCTFail()
                return
            }
            XCTAssert(type(of: model) === ClassRoom.self)
            XCTAssertEqual(model.id, "class-room-001")
            XCTAssertEqual(model.name, "Class Room 202")
            XCTAssertEqual(model.students.count, 3)

            let store = JSONAPIStore(includedRecords: json["included"])
            try jsonModel?.loadIncludedIterative(factory, store: store)

            let john = model.students[0]
            XCTAssertEqual(john.id, "student-001")
            XCTAssertEqual(john.name, "John")
            XCTAssertEqual(john.books.count, 2)
            let firstBook = john.books[0]
            XCTAssertEqual(firstBook.id, "book-001")
            XCTAssertEqual(firstBook.name, "Head First Python")
            XCTAssertEqual(firstBook.isbn, "978-1449382674")
            let secondBook = john.books[1]
            XCTAssertEqual(secondBook.id, "book-002")
            XCTAssertEqual(secondBook.name, "Head First Programming")
            XCTAssertEqual(secondBook.isbn, "978-0596802370")

            let marry = model.students[1]
            XCTAssertEqual(marry.id, "student-002")
            XCTAssertEqual(marry.name, "Marry")
            XCTAssertEqual(marry.books.count, 0)

            let jenny = model.students[2]
            XCTAssertEqual(jenny.id, "student-003")
            XCTAssertEqual(jenny.name, "Jenny")
            XCTAssertEqual(jenny.books.count, 1)
            let thirdBook = jenny.books[0]
            XCTAssertEqual(thirdBook.id, "book-003")
            XCTAssertEqual(thirdBook.name, "Effective Modern C++")
            XCTAssertEqual(thirdBook.isbn, "978-1491903995")
        } catch {
            XCTFail()
        }
    }
}
