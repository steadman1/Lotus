//
//  SpotifyWebAPI.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/27/24.
//

import Foundation

class SpotifyWebAPI_: ObservableObject {
    static let shared = SpotifyWebAPI_() // Singleton instance
    @Published var isAuthenticated = false
    private let clientID = "8acae9ec1c1143afa985a5d52209680d"
    private let clientSecret = "afb769f54dec49f2ba318c42ba7b0a40"
    private let redirectURI = "lotus-for-spotify://spotify-login-callback"
    private let baseURL = "https://api.spotify.com/v1"
    private var accessToken: String?
    
    private init() {}
    
    // Function to handle authentication (simplified version)
    func authenticate(accessToken: String) {
        self.accessToken = accessToken
        DispatchQueue.main.async { self.isAuthenticated = true }
    }
    
    func authenticate(completion: @escaping (Bool) -> Void) {
        completion(false)
    }
    
    func fetchUserID(from spotifyURI: String) -> String? {
        let components = spotifyURI.components(separatedBy: ":")
        guard components.count == 3, components[0] == "spotify", components[1] == "user",
              let username = components.last else {
            print("Invalid Spotify URI")
            return nil
        }
        return username
    }
    
    // Fetch the current user's profile
    func fetchCurrentUserProfile(completion: @escaping (Result<SpotifyProfile, Error>) -> Void) {
        guard let accessToken = accessToken else {
            completion(.failure(SpotifyError.notAuthenticated))
            return
        }
        
        let url = URL(string: "\(baseURL)/me")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(.failure(error!))
                return
            }
            
            do {
                let profile = try JSONDecoder().decode(SpotifyMyProfile.self, from: data)
                completion(.success(profile))
            } catch {
                print("Error decoding profile: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func fetchUserProfile(userURI: String, completion: @escaping (Result<SpotifyOtherProfile, Error>) -> Void) {
        guard let accessToken = accessToken else {
            completion(.failure(SpotifyError.notAuthenticated))
            return
        }
        
        guard let userID = fetchUserID(from: userURI) else {
            completion(.failure(SpotifyError.decodeError))
            return
        }
        
        fetchUserProfile(userID: userID) { result in
            completion(result)
        }
    }
    
    func fetchUserProfile(userID: String, completion: @escaping (Result<SpotifyOtherProfile, Error>) -> Void) {
        guard let accessToken = accessToken else {
            completion(.failure(SpotifyError.notAuthenticated))
            return
        }
        
        let url = URL(string: "\(baseURL)/users/\(userID)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(.failure(error!))
                return
            }
            
            do {
                let profile = try JSONDecoder().decode(SpotifyOtherProfile.self, from: data)
                completion(.success(profile))
            } catch {
                print("Error decoding profile: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func fetchUserProfileImageURL(userURI: String, completion: @escaping (Result<URL, Error>) -> Void) {
        var urlString = "www.google.com"
        fetchUserProfile(userURI: userURI) { result in
            print(result)
            switch result {
            case .success(let profile):
                if profile.images.count > 0 {
                    var maxIndex = 0
                    for i in 0..<profile.images.count {
                        if profile.images[maxIndex].width + profile.images[maxIndex].height
                            < profile.images[i].width + profile.images[i].height {
                            maxIndex = i
                        }
                    }
                    completion(.success(URL(string: profile.images[maxIndex].url)!))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Search for tracks
    func searchTracks(query: String, completion: @escaping (Result<[Track], Error>) -> Void) {
        // Similar to fetchCurrentUserProfile, construct and execute the search request
    }
    
    // Add more API methods as needed...
}

protocol SpotifyProfile {
    var displayName: String { get }
    var externalUrls: ExternalUrls { get }
    var href: String { get }
    var id: String { get }
    var images: [SpotifyImage] { get }
    var type: String { get }
    var uri: String { get }
    var followers: Followers { get }
}

struct SpotifyMyProfile: SpotifyProfile, Codable {
    let displayName: String
    let externalUrls: ExternalUrls
    let href: String
    let id: String
    let images: [SpotifyImage]
    let type: String
    let uri: String
    let followers: Followers
    let country: String
    let product: String
    let explicitContent: ExplicitContent
    let email: String
    let birthdate: String
    let policies: Policies

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case externalUrls = "external_urls"
        case href
        case id
        case images
        case type
        case uri
        case followers
        case country
        case product
        case explicitContent = "explicit_content"
        case email
        case birthdate
        case policies
    }
}

struct SpotifyOtherProfile: SpotifyProfile, Codable {
    let displayName: String
    let externalUrls: ExternalUrls
    let href: String
    let id: String
    let images: [SpotifyImage]
    let type: String
    let uri: String
    let followers: Followers

    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case externalUrls = "external_urls"
        case href
        case id
        case images
        case type
        case uri
        case followers
    }
}

struct ExternalUrls: Codable {
    let spotify: String
}

struct SpotifyImage: Codable {
    let url: String
    let height: Int
    let width: Int
}

struct Followers: Codable {
    let href: String?
    let total: Int
}

struct ExplicitContent: Codable {
    let filterEnabled: Bool
    let filterLocked: Bool

    enum CodingKeys: String, CodingKey {
        case filterEnabled = "filter_enabled"
        case filterLocked = "filter_locked"
    }
}

struct Policies: Codable {
    let optInTrialPremiumOnlyMarket: Bool

    enum CodingKeys: String, CodingKey {
        case optInTrialPremiumOnlyMarket = "opt_in_trial_premium_only_market"
    }
}


enum SpotifyError: Error {
    case notAuthenticated, apiError(String), invalidResponse, decodeError
}
