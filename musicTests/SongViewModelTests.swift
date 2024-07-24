//
//  SongViewModelTests.swift
//  musicTests
//
//  Created by Agni Muhammad on 24/07/24.
//

import XCTest
import Combine
@testable import music

final class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    override func resume() {
        closure()
    }
}

final class MockURLSession: URLSession {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    var data: Data?
    var error: Error?
    
    override func dataTask(with url: URL, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        return MockURLSessionDataTask {
            completionHandler(self.data, nil, self.error)
        }
    }
}

final class SongViewModelTests: XCTestCase {

    var viewModel: SongViewModel!
    var mockSession: MockURLSession!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        super.setUp()
        mockSession = MockURLSession()
        viewModel = SongViewModel(session: mockSession)
        cancellables = []
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockSession = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchSongSuccess() {
        let expectation = self.expectation(description: "Fetch songs")
        
        let mockJSONResponse = """
        {
            "results": [
                {
                    "trackId": 1,
                    "artistName": "Sample Artist",
                    "collectionName": "Sample Album",
                    "trackName": "Sample Song 1",
                    "previewUrl": "https://example.com/sample1.mp3",
                    "artworkUrl60": "https://example.com/sample1.jpg"
                },
                {
                    "trackId": 2,
                    "artistName": "Sample Artist",
                    "collectionName": "Sample Album",
                    "trackName": "Sample Song 2",
                    "previewUrl": "https://example.com/sample2.mp3",
                    "artworkUrl60": "https://example.com/sample2.jpg"
                }
            ]
        }
        """.data(using: .utf8)!
        
        mockSession.data = mockJSONResponse
        
        viewModel.$songs
            .dropFirst()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail("Unexpected error: \(error)")
                }
            }, receiveValue: { songs in
                XCTAssertEqual(songs.count, 2)
                XCTAssertEqual(songs.first?.trackName, "Sample Song 1")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        viewModel.fetchSong()
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testLookupSongSuccess() {
        let expectation = self.expectation(description: "Lookup song by ID")
        
        let mockJSONResponse = """
        {
            "results": [
                {
                    "trackId": 1,
                    "artistName": "Sample Artist",
                    "collectionName": "Sample Album",
                    "trackName": "Sample Song 1",
                    "previewUrl": "https://example.com/sample1.mp3",
                    "artworkUrl60": "https://example.com/sample1.jpg"
                }
            ]
        }
        """.data(using: .utf8)!
        
        mockSession.data = mockJSONResponse
        
        viewModel.$songs
            .dropFirst()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail("Unexpected error: \(error)")
                }
            }, receiveValue: { songs in
                XCTAssertEqual(songs.count, 1)
                XCTAssertEqual(songs.first?.trackName, "Sample Song 1")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        viewModel.lookupSong(by: 1)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
