//
//  ContentView.swift
//  music
//
//  Created by Agni Muhammad on 24/07/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SongViewModel()
    @State private var lookupId: String = ""
    
    var body: some View {
        VStack {
            VStack {
                Text("Music Apps")
                    .font(.title)
                // Search bar
                ClearableTextField(
                    text: $viewModel.searchText,
                    placeholder: "Search artist",
                    onCommit: {
                        if viewModel.searchText.isEmpty {
                            viewModel.clearSongs()
                        } else {
                            viewModel.fetchSong()
                        }
                    }
                )
            }
            .padding(.top)
            
            Spacer()
            
            ZStack {
                // Conditional view rendering
                if viewModel.isFirstLaunch {
                    VStack {
                        Spacer()
                        Image(systemName: "music.note.list")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        Text("Welcome! Please search for a song or artist.")
                            .padding()
                        Spacer()
                    }
                } else if viewModel.noSongsFound {
                    VStack {
                        Spacer()
                        Text("No songs found. Please try a different search.")
                            .padding()
                        Spacer()
                    }
                } else {
                    List(viewModel.songs) { song in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(song.trackName ?? "")
                                Text(song.artistName ?? "")
                                if let collectionName = song.collectionName {
                                    Text(collectionName)
                                }
                            }
                            Spacer()
                            if viewModel.currentSong?.id == song.id && viewModel.isPlaying {
                                Image(systemName: "waveform.path.ecg")
                            }
                        }
                        .onTapGesture {
                            viewModel.playSong(song)
                        }
                    }
                }
                
                // Centered loading indicator in the list area
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                            .padding()
                        Text("Loading...")
                            .foregroundColor(.white) // Set text color to white
                            .padding(.top, 8) // Add some space between the ProgressView and the text
                    }
                    .padding()
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(10)
                }
            }
            
            // Music controls
            if let currentSong = viewModel.currentSong {
                HStack {
                    Button(action: {
                        viewModel.previousSong()
                    }) {
                        Image(systemName: "backward.fill")
                    }
                    Button(action: {
                        viewModel.isPlaying ? viewModel.pauseSong() : viewModel.playSong(currentSong)
                    }) {
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    }
                    Button(action: {
                        viewModel.nextSong()
                    }) {
                        Image(systemName: "forward.fill")
                    }
                }
                .padding()
            }
        }
        .onAppear {
            if viewModel.searchText.isEmpty {
                viewModel.clearSongs()
            } else {
                viewModel.fetchSong()
            }
        }
    }
}

#Preview {
    ContentView()
}


