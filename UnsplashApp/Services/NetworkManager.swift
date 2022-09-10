//
//  NetworkManager.swift
//  UnsplashApp
//
//  Created by Никита Горбунов on 05.09.2022.
//

import Foundation

enum NetworkError: Error {
    case urlError
    case serverError
    case notData
    case decodeError
}


class NetworkManager {
    
    private var session: URLSession
    private var components = URLComponents()
    private var key = "3FI_JUhzKWxppxOfnPnpaqeX1N5HMaiyWvRadajvleU"
    private let count = 30
    
    init() {
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration)
        components.scheme = "https"
        components.host = "api.unsplash.com"
    }
    
    private func getURL(path: String, params: [String:String]) -> URL? {
        components.path = path
        components.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        
        return components.url
    }
    
    func getRandomPhotos(completion: @escaping (Result<[Photo], NetworkError>) -> Void) {
        let path = "/photos/random"
        let parameters: [String:String] = ["count": "\(count)", "client_id": "\(key)"]
        guard let url = getURL(path: path, params: parameters) else { return }
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.serverError))
                debugPrint(String(describing: error))
                return
            }
            
            guard let data = data else {
                completion(.failure(.notData))
                debugPrint(String(describing: error))
                return
            }
            
            do {
                let result = try JSONDecoder().decode([Photo].self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(.decodeError))
                debugPrint("Failed to decode...")
            }
        }
        
        task.resume()
    }
    
    func getSearchPhotos(query: String, completion: @escaping (Result<[Photo], NetworkError>) -> Void) {
        let path = "/search/photos"
        let parameters: [String:String] = ["query": "\(query)", "client_id": "\(key)"]
        guard let url = getURL(path: path, params: parameters) else { return }
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.serverError))
                debugPrint(String(describing: error))
                return
            }
            
            guard let data = data
            else {
                completion(.failure(.notData))
                debugPrint(String(describing: error))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(SearchPhoto.self, from: data)
                completion(.success(result.results ?? []))
            } catch {
                completion(.failure(.decodeError))
                debugPrint("Failed to decode...")
            }
        }
        
        task.resume()
    }
}
