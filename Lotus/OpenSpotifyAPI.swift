//
//  Test.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/26/24.
//

import Foundation

// Define a structure for decoding the access token JSON response
struct AccessToken: Decodable {
    let accessToken: String
}

struct SpotifyFriendActivity: Codable {
    let friends: [Friend]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedFriends = try container.decode([Friend].self, forKey: .friends)
        // Reverse the decoded array
        self.friends = decodedFriends.reversed()
    }
    
    enum CodingKeys: String, CodingKey {
        case friends
    }
}

struct Friend: Codable, Identifiable {
    var id: String { user.uri }
    let timestamp: Int64
    let user: User
    let track: Track
}

struct User: Codable {
    let uri: String
    let name: String
}

struct Track: Codable {
    let uri: String
    let name: String
    let imageUrl: URL
    let album: Album
    let artist: Artist
    let context: TrackContext
}

struct Album: Codable {
    let uri: String
    let name: String
}

struct Artist: Codable {
    let uri: String
    let name: String
}

struct TrackContext: Codable {
    let uri: String
    let name: String
    let index: Int
}

class OpenSpotifyAPI {
    let session = URLSession.shared
    
    func getWebAccessToken(spDcCookie: String, completion: @escaping (AccessToken?) -> Void) {
        guard let url = URL(string: "https://open.spotify.com/get_access_token?reason=transport&productType=web_player") else { return }
        
        var request = URLRequest(url: url)
        request.addValue("sp_dc=\(spDcCookie)", forHTTPHeaderField: "Cookie")
        
        session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let accessToken = try JSONDecoder().decode(AccessToken.self, from: data)
                completion(accessToken)
            } catch {
                print("Error decoding access token: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    func getFriendActivity(webAccessToken: String, completion: @escaping (SpotifyFriendActivity?) -> Void) {
        guard let url = URL(string: "https://spclient.wg.spotify.com/presence-view/v1/buddylist") else { return }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(webAccessToken)", forHTTPHeaderField: "Authorization")
        
        session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let friendActivity = try JSONDecoder().decode(SpotifyFriendActivity.self, from: data)
                completion(friendActivity)
            } catch {
                print("Error decoding friend activity: \(error)")
                completion(nil)
            }
        }.resume()
    }
}

