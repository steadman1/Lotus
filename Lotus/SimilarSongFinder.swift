//
//  SimilarSongFinder.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/27/24.
//

import Foundation
import SwiftSoup

class SimilarSongFinder {
    static func fetchSimilarSongs(completion: @escaping (Result<[String], Error>) -> Void) {
        let url = URL(string: "https://example.com")! // Replace "https://example.com" with your target URL
        let session = URLSession.shared

        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching the URL: \(error?.localizedDescription ?? "Unknown error")")
                completion(.failure(error!))
                return
            }
            
            if let html = String(data: data, encoding: .utf8) {
                completion(.success(extractSpotifyLinks(from: html)))
            } else {
                completion(.failure(SpotifyError.decodeError))
            }
        }

        task.resume()
    }
    
    static func extractSpotifyLinks(from html: String) -> [String] {
        var spotifyLinks: [String] = []
        
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let links: Elements = try doc.select("a[href]") // Select all <a> tags with an href attribute
            
            for link in links.array() {
                let href: String = try link.attr("href")
                if href.contains("https://open.spotify.com/track/") {
                    spotifyLinks.append(href)
                }
            }
        } catch Exception.Error(let type, let message) {
            print("Got an error of type \(type) with message \(message)")
        } catch {
            print("An unknown error occurred")
        }
        
        return spotifyLinks
    }
}
