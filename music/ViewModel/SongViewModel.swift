//
//  SongViewModel.swift
//  music
//
//  Created by Agni Muhammad on 24/07/24.
//

import Foundation
import Combine
import AVFoundation

class SongViewModel: ObservableObject {
    @Published var songs: [Song] = []
    @Published var searchText: String = ""
    @Published var isPlaying: Bool = false
    @Published var currentSong: Song?
    @Published var isLoading: Bool = false
    @Published var isFirstLaunch: Bool = true
    @Published var noSongsFound: Bool = false
    
    private var cancellable = Set<AnyCancellable>()
    private let searchBaseUrl = "https://itunes.apple.com/search?media=music&country=ID&term=%22"
    private var player: AVPlayer?
    private var session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func fetchSong() {
        guard let url = URL(string: searchBaseUrl + searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            print("Invalid URL")
            return
        }
        
        isLoading = true
        noSongsFound = false
        
        session.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: SongResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    print("Combine pipeline finished successfully")
                case .failure(let error):
                    print("Received error: \(error)")
                    self?.songs = []
                    self?.noSongsFound = true
                }
                self?.isLoading = false
            }, receiveValue: { [weak self] response in
                print("Received response: \(response.results)")
                self?.songs = response.results
                self?.noSongsFound = response.results.isEmpty
                self?.isFirstLaunch = false
            })
            .store(in: &cancellable)
    }
    
    func playSong(_ song: Song) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error.localizedDescription)")
        }
        
        if let url = URL(string: song.previewUrl ?? "") {
            player = AVPlayer(url: url)
            player?.play()
            currentSong = song
            isPlaying = true
        }
    }
    
    func pauseSong() {
        player?.pause()
        isPlaying = false
    }
    
    func nextSong() {
        guard let currentSong = currentSong, let currentIndex = songs.firstIndex(where: { $0.id == currentSong.id }) else { return }
        let nextIndex = (currentIndex + 1) % songs.count
        playSong(songs[nextIndex])
    }
    
    func previousSong() {
        guard let currentSong = currentSong, let currentIndex = songs.firstIndex(where: { $0.id == currentSong.id }) else { return }
        let previousIndex = (currentIndex - 1 + songs.count) % songs.count
        playSong(songs[previousIndex])
    }
    
    func clearSongs() {
        songs.removeAll()
        currentSong = nil
        isPlaying = false
        isFirstLaunch = true
        noSongsFound = false
    }
}

struct SongResponse: Decodable {
    let results: [Song]
}

