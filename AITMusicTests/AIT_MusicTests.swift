//
//  musicTests.swift
//  musicTests
//
//  Created by Agni Muhammad on 24/07/24.
//

import XCTest
@testable import AIT_Music

class SongTests: XCTestCase {

    func testDecodeSong() {
        let jsonData = """
        {
            "trackId": 1,
            "artistName": "Sample Artist",
            "collectionName": "Sample Album",
            "trackName": "Sample Song",
            "previewUrl": "https://example.com/sample.mp3",
            "artworkUrl60": "https://example.com/sample.jpg"
        }
        """.data(using: .utf8)!

        do {
            let song = try JSONDecoder().decode(Song.self, from: jsonData)
            XCTAssertEqual(song.id, 1)
            XCTAssertEqual(song.artistName, "Sample Artist")
            XCTAssertEqual(song.collectionName, "Sample Album")
            XCTAssertEqual(song.trackName, "Sample Song")
            XCTAssertEqual(song.previewUrl, "https://example.com/sample.mp3")
            XCTAssertEqual(song.artworkUrl60, "https://example.com/sample.jpg")
        } catch {
            XCTFail("Decoding failed: \(error)")
        }
    }

    func testDecodeSongMissingOptionalFields() {
        let jsonData = """
        {
            "trackId": 2,
            "artistName": "Another Artist",
            "trackName": "Another Song"
        }
        """.data(using: .utf8)!

        do {
            let song = try JSONDecoder().decode(Song.self, from: jsonData)
            XCTAssertEqual(song.id, 2)
            XCTAssertEqual(song.artistName, "Another Artist")
            XCTAssertNil(song.collectionName)
            XCTAssertEqual(song.trackName, "Another Song")
            XCTAssertNil(song.previewUrl)
            XCTAssertNil(song.artworkUrl60)
        } catch {
            XCTFail("Decoding failed: \(error)")
        }
    }

    func testDecodeSongWithInvalidData() {
        let jsonData = """
        {
            "trackId": "invalid_id",
            "artistName": "Invalid Artist",
            "trackName": "Invalid Song"
        }
        """.data(using: .utf8)!

        // Attempt to decode the JSON data to a Song object and expect failure
        XCTAssertThrowsError(try JSONDecoder().decode(Song.self, from: jsonData)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }
}
