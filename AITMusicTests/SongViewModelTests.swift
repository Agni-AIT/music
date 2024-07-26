//
//  SongViewModelTests.swift
//  AITMusicTests
//
//  Created by Agni Muhammad on 25/07/24.
//

import XCTest
import Combine
@testable import AIT_Music


protocol NetworkingService {
    func fetchData(url: URL, completion: @escaping (Data?, Error?) -> Void)
}

class MockSongsNetworkService: SongsNetworkServiceProtocol {
    var term: String = ""
    var shouldReturnError = false
    var mockData: Data?
    
    func setTerm(_ term: String) {
        self.term = term
    }
    
    func fetchData(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        if shouldReturnError {
            completion(nil, NSError(domain: "TestError", code: 0, userInfo: nil))
        } else {
            completion(mockData, nil)
        }
    }
}

final class SongViewModelTests: XCTestCase {
    
    var viewModel: SongViewModel!
    var mockNetworkService: MockSongsNetworkService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockNetworkService = MockSongsNetworkService()
        let apiService = APIService(networkingService: mockNetworkService)
        viewModel = SongViewModel(session: apiService)
        cancellables = []
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockNetworkService = nil
        cancellables = nil
        try super.tearDownWithError()
    }
    
    func testFetchSongsSuccess() {
        let expectation = self.expectation(description: "Fetch songs")
        
        let mockJSONResponse = """
        {
            "results": [
                {
                    "trackId": 120954025,
                    "artistName": "Jack Johnson",
                    "collectionName": "Sing-a-Longs and Lullabies for the Film Curious George",
                    "trackName": "Upside Down",
                    "previewUrl": "http://a1099.itunes.apple.com/r10/Music/f9/54/43/mzi.gqvqlvcq.aac.p.m4p",
                    "artworkUrl60": "http://a1.itunes.apple.com/r10/Music/3b/6a/33/mzi.qzdqwsel.60x60-50.jpg"
                }
            ]
        }
        """.data(using: .utf8)!
        
        mockNetworkService.mockData = mockJSONResponse
        
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
                XCTAssertEqual(songs.first?.trackName, "Upside Down")
                XCTAssertEqual(songs.first?.artistName, "Jack Johnson")
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        viewModel.fetchSong()
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFetchSongsFailure() {
        let expectation = self.expectation(description: "Fetch songs failure")
        
        mockNetworkService.shouldReturnError = true
        
        viewModel.$noSongsFound
            .first(where: { $0 == true }) 
            .sink { noSongsFound in
                XCTAssertTrue(noSongsFound)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchSong()
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testPlaySong() {
        let mockSong = Song(
            id: 120954025,
            artistName: "Jack Johnson",
            collectionName: "Sing-a-Longs and Lullabies for the Film Curious George",
            trackName: "Upside Down",
            previewUrl: "http://a1099.itunes.apple.com/r10/Music/f9/54/43/mzi.gqvqlvcq.aac.p.m4p",
            artworkUrl60: "http://a1.itunes.apple.com/r10/Music/3b/6a/33/mzi.qzdqwsel.60x60-50.jpg"
        )
        
        viewModel.playSong(mockSong)
        
        XCTAssertTrue(viewModel.isPlaying)
        XCTAssertEqual(viewModel.currentSong?.trackName, "Upside Down")
    }
    
    func testPauseSong() {
        let mockSong = Song(
            id: 120954025,
            artistName: "Jack Johnson",
            collectionName: "Sing-a-Longs and Lullabies for the Film Curious George",
            trackName: "Upside Down",
            previewUrl: "http://a1099.itunes.apple.com/r10/Music/f9/54/43/mzi.gqvqlvcq.aac.p.m4p",
            artworkUrl60: "http://a1.itunes.apple.com/r10/Music/3b/6a/33/mzi.qzdqwsel.60x60-50.jpg"
        )
        
        viewModel.playSong(mockSong)
        viewModel.pauseSong()
        
        XCTAssertFalse(viewModel.isPlaying)
    }
    
    func testNextSong() {
        let mockSongs = [
            Song(id: 1, artistName: "Artist 1", collectionName: "Album 1", trackName: "Song 1", previewUrl: nil, artworkUrl60: nil),
            Song(id: 2, artistName: "Artist 2", collectionName: "Album 2", trackName: "Song 2", previewUrl: nil, artworkUrl60: nil)
        ]
        viewModel.songs = mockSongs
        viewModel.currentSong = mockSongs[0]
        
        print("agni Before nextSong: \(viewModel.currentSong?.trackName ?? "nil")")
        viewModel.nextSong()
        print("agni after nextSong: \(viewModel.currentSong?.trackName ?? "nil")")
        
        XCTAssertEqual(viewModel.currentSong?.trackName, "Song 2")
    }
    
    func testPreviousSong() {
        let mockSongs = [
            Song(id: 1, artistName: "Artist 1", collectionName: "Album 1", trackName: "Song 1", previewUrl: nil, artworkUrl60: nil),
            Song(id: 2, artistName: "Artist 2", collectionName: "Album 2", trackName: "Song 2", previewUrl: nil, artworkUrl60: nil)
        ]
        viewModel.songs = mockSongs
        viewModel.currentSong = mockSongs[1]
        
        print("agni before previousSong: \(viewModel.currentSong?.trackName ?? "nil")")
        viewModel.previousSong()
        print("agni after previousSong: \(viewModel.currentSong?.trackName ?? "nil")")
        
        XCTAssertEqual(viewModel.currentSong?.trackName, "Song 1")
    }
}
