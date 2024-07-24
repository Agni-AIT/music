//
//  Song.swift
//  music
//
//  Created by Agni Muhammad on 24/07/24.
//

import Foundation

struct Song: Identifiable, Decodable {
    let id: Int
    let artistName: String
    let collectionName: String?
    let trackName: String
    let previewUrl: String?
    let artworkUrl60: String?
    
    private enum CodingKeys: String, CodingKey {
        case id = "trackId"
        case artistName
        case collectionName
        case trackName
        case previewUrl
        case artworkUrl60
    }
}
