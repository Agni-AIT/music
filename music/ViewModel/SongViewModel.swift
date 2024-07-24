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
    @Published var searchText: String = "Justin Bieber"
    @Published var isPlaying: Bool = false
    @Published var currentSong: Song?
    
    private var cancellable = Set<AnyCancellable>()
    private let searchBaseUrl = "https://itunes.apple.com/search?term="
    private let lookupBaseUrl = "https://itunes.apple.com/lookup?id="
    private var player: AVPlayer?
    
    init() {
        fetchSong()
    }
    
    func fetchSong() {
        guard let url = URL(string: searchBaseUrl + searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }
        
        URLSession.shared.dataTaskPublisher(for:url)
            .map { $0.data }
            .decode(type: SongResponse.self, decoder: JSONDecoder())
            .replaceError(with: SongResponse(results: []))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                self?.songs = response.results
            }
            .store(in: &cancellable)
    }
    
    func lookupSong(by id: Int) {
        guard let url = URL(string: lookupBaseUrl + "\(id)") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: SongResponse.self, decoder: JSONDecoder())
            .replaceError(with: SongResponse(results: []))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                self?.songs = response.results
            }
            .store(in: &cancellable)
    }
    
    func playSong(_ song: Song) {
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
}

struct SongResponse: Decodable {
    let results: [Song]
}
