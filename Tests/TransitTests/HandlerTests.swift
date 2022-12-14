//
//  File.swift
//  
//
//  Created by Soroush Khanlou on 8/23/22.
//

import Foundation
import Transit
import XCTest

final class HandlerTests: XCTestCase {


    func testSetSimple() throws {
        // set_simple.json
        let data = """
        ["~#set",[1,3,2]]
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder().decode(Set<Int>.self, from: data)

        XCTAssertEqual(decoded, Set([1,2,3]))
    }

    func testSetEmpty() throws {
        // set_empty.json
        let data = """
        ["~#set",[]]
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder().decode(Set<Int>.self, from: data)

        XCTAssertEqual(decoded, Set([]))
    }

    func testSetInMap() throws {
        let data = """
        ["^ ","~:a_set",["~#set",[1,3,2]],"~:an_int",14]
        """
        .data(using: .utf8)!

        struct Result: Codable {
            let a_set: Set<Int>
            let an_int: Int
        }
        let decoded = try TransitDecoder().decode(Result.self, from: data)

        XCTAssertEqual(decoded.a_set, Set([1, 2, 3]))
        XCTAssertEqual(decoded.an_int, 14)
    }

    func testSetWithDates() throws {
        let data = """
        ["~#set",["~m946728000000", "~t1776-07-04T12:00:00.000Z"]]
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder().decode(Set<Date>.self, from: data)

        XCTAssertEqual(decoded, Set([Date(timeIntervalSince1970: -6106017600), Date(timeIntervalSince1970: 946728000)]))
    }

    func testListSimple() throws {
        // set_simple.json
        let data = """
        ["~#list",[1,3,2]]
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder().decode([Int].self, from: data)

        XCTAssertEqual(decoded, [1,3,2])
    }

    func testListEmpty() throws {
        // list_empty.json
        let data = """
        ["~#list",[]]
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder().decode([Int].self, from: data)

        XCTAssertEqual(decoded, [])
    }

    func testListInMap() throws {
        let data = """
        ["^ ","~:a_list",["~#list",[1,3,2]],"~:an_int",14]
        """
        .data(using: .utf8)!

        struct Result: Codable {
            let a_list: [Int]
            let an_int: Int
        }
        let decoded = try TransitDecoder().decode(Result.self, from: data)

        XCTAssertEqual(decoded.a_list, [1, 3, 2])
        XCTAssertEqual(decoded.an_int, 14)
    }

    func testURIMap() throws {
        // uri_map.json
        let data = """
        ["^ ", "~:uri", "~rhttp://example.com"]
        """
        .data(using: .utf8)! // not parsing: "~rhttp://www.?????????.com/"

        struct Result: Codable {
            let uri: URL
        }
        let decoded = try TransitDecoder().decode(Result.self, from: data)

        XCTAssertEqual(decoded.uri, URL(string: "http://example.com"))
    }

    func testURIs() throws {
        // uris.json
        let data = """
        ["~rhttp://example.com","~rftp://example.com","~rfile:///path/to/file.txt"]
        """
        .data(using: .utf8)! // not parsing: "~rhttp://www.?????????.com/"

        let decoded = try TransitDecoder().decode([URL].self, from: data)

        let expectedURLs = [
            URL(string: "http://example.com"),
            URL(string: "ftp://example.com"),
            URL(string: "file:///path/to/file.txt"),
//            URL(string: "http://www.?????????.com/"),
        ].compactMap({ $0 })

        XCTAssertEqual(decoded[0], expectedURLs[0])
        XCTAssertEqual(decoded[1], expectedURLs[1])
        XCTAssertEqual(decoded[2], expectedURLs[2])
    }

    func testUUIDMap() throws {
        // uri_map.json
        let uuid = UUID().uuidString
        let data = """
        ["^ ", "~:uuid", "~u\(uuid)"]
        """
        .data(using: .utf8)!

        struct Result: Codable {
            let uuid: UUID
        }
        let decoded = try TransitDecoder().decode(Result.self, from: data)

        XCTAssertEqual(decoded.uuid.uuidString, uuid)
    }

    func testUUIDs() throws {
        // uuids.json
        let data = """
            ["~u5a2cbea3-e8c6-428b-b525-21239370dd55","~ud1dc64fa-da79-444b-9fa4-d4412f427289","~u501a978e-3a3e-4060-b3be-1cf2bd4b1a38","~ub3ba141a-a776-48e4-9fae-a28ea8571f58"]
        """
        .data(using: .utf8)!

        let decoded = try TransitDecoder().decode([UUID].self, from: data)

        let expectedUUIDs = [
            "5a2cbea3-e8c6-428b-b525-21239370dd55",
            "d1dc64fa-da79-444b-9fa4-d4412f427289",
            "501a978e-3a3e-4060-b3be-1cf2bd4b1a38",
            "b3ba141a-a776-48e4-9fae-a28ea8571f58"
        ].compactMap({ UUID(uuidString: $0) })

        XCTAssertEqual(decoded[0], expectedUUIDs[0])
        XCTAssertEqual(decoded[1], expectedUUIDs[1])
        XCTAssertEqual(decoded[2], expectedUUIDs[2])
        XCTAssertEqual(decoded[3], expectedUUIDs[3])
    }


}
