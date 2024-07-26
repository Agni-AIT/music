//
//  SongNetworkService.swift
//  music
//
//  Created by Agni Muhammad on 26/07/24.
//

import Foundation

protocol SongsNetworkServiceProtocol: NetworkingService {
    func setTerm(_ term: String)
}

class SongsNetworkService: SongsNetworkServiceProtocol {
    var session = URLSession.shared
    var urlComponents = URLComponents()
    var term: String = ""
    
    init() {}
    
    func setTerm(_ term: String) {
        self.term = term
    }
    
    func fetchData(url: URL, completion: @escaping (Data?, Error?) -> Void) {
        let request = URLRequest(url: url)
        
        urlComponents.queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "country", value: "ID"),
            URLQueryItem(name: "media", value: "music")
        ]
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, nil)
                return
            }
            
            completion(data, nil)
        }
        
        task.resume()
    }
}

