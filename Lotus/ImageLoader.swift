//
//  ImageLoader.swift
//  Lotus
//
//  Created by Spencer Steadman on 4/4/24.
//

import Foundation
import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    @Published var profileData: Data = Data()
    @Published var trackData: Data = Data()

    func loadImages(profileURL: URL?, trackURL: URL?, action: @escaping (Data, Data) -> Void) {
        let dispatchGroup = DispatchGroup()

        if let profileURL {
            dispatchGroup.enter()
            URLSession.shared.dataTask(with: profileURL) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.profileData = image.wxCompress(type: .profile)
                    }
                }
                dispatchGroup.leave()
            }.resume()
        }

        if let trackURL {
            dispatchGroup.enter()
            URLSession.shared.dataTask(with: trackURL) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.trackData = image.wxCompress(type: .track)
                    }
                }
                dispatchGroup.leave()
            }.resume()
        }

        dispatchGroup.notify(queue: .main) {
            action(self.profileData, self.trackData)
        }
    }
}
