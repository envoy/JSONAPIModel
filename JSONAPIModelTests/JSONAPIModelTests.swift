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
@testable import JSONAPIModel

class JSONAPIModelTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func readJSON(fileName: String) -> JSON {
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

    func testLoadIncludedIterativeSafeWithArticles() {
        let factory = JSONAPIFactory.defaultFactory
        let json = readJSON(fileName: "articles")
        do {
            let jsonModel = try factory.createModel(json["data"][0])
            guard let article = jsonModel as? Article else {
                XCTFail("Should create Article model")
                return
            }

            // Verify basic article attributes
            XCTAssertEqual(article.id, "1")
            XCTAssertEqual(article.title, "JSON:API paints my bikeshed!")

            // Create store and load included data using safe iterative approach
            let store = JSONAPIStore(includedRecords: json["included"])
            try jsonModel?.loadIncludedIterative(factory, store: store)

            // Verify author relationship is loaded
            XCTAssertNotNil(article.author)
            XCTAssertEqual(article.author?.id, "9")
            XCTAssertEqual(article.author?.firstName, "Dan")
            XCTAssertEqual(article.author?.lastName, "Gebhardt")
            XCTAssertEqual(article.author?.twitter, "dgeb")

            // Verify comments relationship is loaded
            XCTAssertEqual(article.comments.count, 2)

            let firstComment = article.comments[0]
            XCTAssertEqual(firstComment.id, "5")
            XCTAssertEqual(firstComment.body, "First!")

            let secondComment = article.comments[1]
            XCTAssertEqual(secondComment.id, "12")
            XCTAssertEqual(secondComment.body, "I like XML better")
            XCTAssertNotNil(secondComment.author)
            XCTAssertEqual(secondComment.author?.id, "9")
            XCTAssertEqual(secondComment.author?.firstName, "Dan")

            // **CRITICAL TEST**: Both the article author and comment author should have the same Id, but should be different instances
            // This prevents duplicate objects and potential retain cycles
            if let articleAuthor = article.author,
               let commentAuthor = secondComment.author,
               articleAuthor.id == commentAuthor.id {
                XCTAssertTrue(articleAuthor !== commentAuthor,
                             "Article author and comment author should NOT be the same instance to prevent duplicates and retain cycles")
            } else {
                XCTFail("Both authors should be non-nil")
            }

        } catch {
            XCTFail("Test failed with error: \(error)")
        }
    }
}
