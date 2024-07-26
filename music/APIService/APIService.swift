import Foundation


protocol NetworkingService {
    func fetchData(url: URL, completion: @escaping (Data?, Error?) -> Void)
}

class APIService {
    private let networkingService: SongsNetworkServiceProtocol
    
    init(networkingService: SongsNetworkServiceProtocol) {
        self.networkingService = networkingService
    }
    
    func searchSongs(term: String, completion: @escaping (Result<[Song], Error>) -> Void) {
        guard let url = URL(string: "https://itunes.apple.com/search?term=\(term)") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        networkingService.fetchData(url: url) { data, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(APIError.networkError(NSError(domain: "No data", code: 0, userInfo: nil))))
                return
            }
            let decoder = JSONDecoder()
            do {
                let songsResponse = try decoder.decode(SongResponse.self, from: data)
                completion(.success(songsResponse.results))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func setTerm(_ term: String) {
        networkingService.setTerm(term)
    }
}
