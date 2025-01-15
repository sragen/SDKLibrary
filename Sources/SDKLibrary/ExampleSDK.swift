//
//  File.swift
//  SDKLibrary
//
//  Created by Bluebird Macbook on 14/01/25.
//

import Foundation

/// A public class that provides methods to interact with the ExampleAPI.
public class ExampleSDK {
    
    // MARK: - Properties
    
    /// The API key used for authentication.
    private let apiKey: String
    
    /// The base URL for the API.
    private let baseURL: URL
    
    // MARK: - Initializer
    
    /// Initializes the SDK with the API key.
    ///
    /// - Parameters:
    ///   - apiKey: Your API key for authenticating with the ExampleAPI.
    ///   - baseURL: The base URL for the API (default is "https://api.example.com").
    public init(apiKey: String, baseURL: String = "https://api.example.com") {
        self.apiKey = apiKey
        self.baseURL = URL(string: baseURL)!
    }
    
    // MARK: - Public Functions
    
    /// Fetches a list of items from the API.
    ///
    /// - Parameters:
    ///   - completion: A closure that gets called with the result of the API request.
    public func fetchItems(completion: @escaping (Result<[String], Error>) -> Void) {
        let endpoint = "/items"
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            completion(.failure(SDKError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(SDKError.noData))
                return
            }
            
            do {
                let items = try JSONDecoder().decode([String].self, from: data)
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    /// Submits an item to the API.
    ///
    /// - Parameters:
    ///   - item: The item to submit.
    ///   - completion: A closure that gets called with the result of the API request.
    public func submitItem(_ item: String, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "/submit"
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            completion(.failure(SDKError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["item": item])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(SDKError.noData))
                return
            }
            
            if let message = String(data: data, encoding: .utf8) {
                completion(.success(message))
            } else {
                completion(.failure(SDKError.invalidResponse))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Private Helpers
    
    /// An enumeration of SDK-specific errors.
    private enum SDKError: Error {
        case invalidURL
        case noData
        case invalidResponse
    }
}
