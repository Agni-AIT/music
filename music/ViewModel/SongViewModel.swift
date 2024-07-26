//
//  SongViewModel.swift
//  music
//
//  Created by Agni Muhammad on 24/07/24.
//

import Foundation
import Combine
import AVFoundation

import Foundation
import Combine
import AVFoundation

protocol SongViewModelDelegate: AnyObject {
    func viewModelDidUpdateSongs(_ viewModel: SongViewModel)
    func viewModelDidUpdatePlayingState(_ viewModel: SongViewModel)
    func viewModelDidUpdateLoadingState(_ viewModel: SongViewModel)
    func viewModelDidEncounterError(_ viewModel: SongViewModel, error: Error)
    func viewModelDidStartPlayingMusic(_ viewModel: SongViewModel)
    func viewModelDidUpdateCurrentSong(_ viewModel: SongViewModel)
}

class SongViewModel: ObservableObject {
    weak var delegate: SongViewModelDelegate?
    
    @Published var songs: [Song] = []
    @Published var searchText: String = "" {
        didSet {
            session.setTerm(searchText)
        }
    }
    @Published var isPlaying: Bool = false {
        didSet {
            delegate?.viewModelDidUpdatePlayingState(self)
        }
    }
    @Published var currentSong: Song? {
        didSet {
            delegate?.viewModelDidUpdateCurrentSong(self)
        }
    }
    @Published var isLoading: Bool = false {
        didSet {
            delegate?.viewModelDidUpdateLoadingState(self)
        }
    }
    @Published var isFirstLaunch: Bool = true
    @Published var noSongsFound: Bool = false
    
    private var cancellable = Set<AnyCancellable>()
    private var player: AVPlayer?
    public var session: APIService
    
    init(session: APIService = APIService(networkingService: SongsNetworkService())) {
        self.session = session
        self.session.setTerm(searchText)
    }
    
    func fetchSong() {
        isLoading = true
        
        session.searchSongs(term: searchText) { [weak self] (result: Result<[Song], Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isLoading = false
                self.noSongsFound = false
                self.isFirstLaunch = false
                
                switch result {
                case .success(let songs):
                    self.songs = songs
                    self.delegate?.viewModelDidUpdateSongs(self)
                case .failure(let error):
                    self.songs = []
                    self.noSongsFound = true
                    self.delegate?.viewModelDidEncounterError(self, error: error)
                }
            }
        }
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
            delegate?.viewModelDidStartPlayingMusic(self)
        } else {
            currentSong = song
            isPlaying = true
            delegate?.viewModelDidStartPlayingMusic(self)
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
