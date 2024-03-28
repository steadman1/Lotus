//
//  FriendActivity.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/27/24.
//

import SwiftUI
import SteadmanUI

struct FriendActivity: View {
    @State var imageURLs: [URL?] = []
    
    let spotifyWebAPI = SpotifyWebAPI.shared
    let friendActivity: SpotifyFriendActivity
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                HStack(spacing: Screen.halfPadding) {
                    ForEach(Array(zip(friendActivity.friends.indices, friendActivity.friends)), id: \.0) { index, friend in
                        ZStack {
                            if imageURLs.count > index {
                                AsyncImage(url: imageURLs[index]) { phase in
                                    switch phase {
                                    case .empty:
                                        Circle()
                                            .foregroundColor(Color.gray)
                                    case .failure:
                                        Text("Failed to fetch image")
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill) // Changing this to .fit shows the buttons
                                    @unknown default:
                                        fatalError()
                                    }
                                }.frame(width: geometry.size.height, height: geometry.size.height)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                            }
                        }.onAppear {
                            imageURLs.append(nil)
                            spotifyWebAPI.fetchUserProfileImageURL(userURI: friend.user.uri) { result in
                                switch result {
                                case .success(let url):
                                    imageURLs[index] = url
                                case .failure(let error):
                                    print("no good")
                                }
                            }
                        }
                    }
                }.padding(.horizontal, Screen.padding)
            }.scrollIndicators(.never)
                .onAppear {
                    spotifyWebAPI.fetchCurrentUserProfile { result in
                        switch result {
                        case .success(let profile):
                            print(profile)
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
        }
    }
}
