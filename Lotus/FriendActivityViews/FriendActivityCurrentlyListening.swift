//
//  FriendActivityCurrentlyListening.swift
//  Lotus
//
//  Created by Spencer Steadman on 4/2/24.
//

import SwiftUI
import SteadmanUI
import Combine

struct FriendActivityCurrentlyListening: View {
    @EnvironmentObject var screen: Screen
    @EnvironmentObject var defaults: ObservableDefaults
    @EnvironmentObject var spotify: Spotify
    
    @State var friendActivity: SpotifyFriendActivity? = nil
    
    private let itemSize: CGFloat = 160
    
    var body: some View {
        VStack {
            if friendActivity != nil && !friendActivity!.friends.isEmpty {
                FriendActivityCarousel(items: friendActivity!.friends, itemSize: itemSize)
            } else {
                BlankCarousel(itemSize: itemSize)
            }
            
        }.padding(.vertical, Screen.padding)
        .onAppear {
            spotify.open_api.fetchFriendActivity { result in
                self.friendActivity = result
            }
        }
    }
}

struct FriendActivityCarousel: View {
    @EnvironmentObject var screen: Screen
    @EnvironmentObject var spotify: Spotify
    
    @State var offset: CGFloat = 0
    @State var imageURLs: [URL?]
    @State var cancellables = Set<AnyCancellable>()
    
    let items: [Friend]
    let itemSize: CGFloat
    
    private let returnButtonSize: CGFloat = 48
    private let profileSize: CGFloat = 32
    
    init(items: [Friend], itemSize: CGFloat) {
        self.items = items
        self.itemSize = itemSize
        self._imageURLs = State(initialValue: Array(repeating: nil, count: items.count))
    }
    
    var body: some View {
        let cardHeight: CGFloat = itemSize + Screen.halfPadding * 5 + profileSize
            + "|\n|".heightOfString(usingFont: Font.uiSansBody)
            + "|".heightOfString(usingFont: Font.uiSerifBody)
        VStack {
            ACarousel(items, itemWidth: itemSize, spacing: 0, headspace: 0) { index, offset, item in
                VStack(spacing: Screen.halfPadding) {
                    ZStack(alignment: .topLeading) {
                        AsyncImage(url: item.track.imageUrl.convertToHTTPS()) { phase in
                            ZStack {
                                Rectangle()
                                    .frame(width: itemSize, height: itemSize)
                                    .foregroundStyle(Color.foreground)
                                
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .frame(width: itemSize, height: itemSize)
                                        .background(Color.background)
                                        .transition(.opacity.animation(.snappy()))
                                default:
                                    EmptyView()
                                }
                            }
                        }
                        ZStack {
                            if imageURLs.count > index && imageURLs[index] != nil {
                                AsyncImage(url: imageURLs[index]) { phase in
                                    ZStack {
                                        Rectangle()
                                            .frame(width: profileSize, height: profileSize)
                                            .foregroundStyle(Color.foreground)

                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .background(Color.background)
                                                .transition(.opacity.animation(.snappy()))
                                        default:
                                            EmptyView()
                                        }
                                    }
                                }.frame(width: profileSize, height: profileSize)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .frame(width: profileSize, height: profileSize)
                                    .foregroundStyle(Color.foreground)
                            }
                        }.frame(width: profileSize, height: profileSize)
                            .padding(1)
                            .background(Color.foreground)
                            .clipShape(Circle())
                            .padding(Screen.halfPadding / 2)
                    }
                    VStack {
                        Text(item.track.name)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .font(.sansBody)
                        Text(item.track.artist.name)
                            .lineLimit(1)
                            .font(.serifBody)
                    }.padding(.horizontal, Screen.halfPadding / 2)
                }//.onChange(of: offset) { self.offset = $1 }
                    .onAppear {
                        fetchAndAddUserProfileURL(with: item.user.uri, at: index)
                    }
            } returnView: {
                ZStack {
                    Circle()
                        .stroke(Color.foreground, lineWidth: 1)
                    Image(.chevronLeft)
                        .font(.serifBody)
                        .foregroundStyle(Color.foreground)
                }.frame(width: returnButtonSize, height: returnButtonSize)
                    .padding(.horizontal, Screen.padding)
                    .padding(.top, itemSize / 2 - returnButtonSize / 2)
            }.frame(height: cardHeight) // tall characters
        }.frame(maxWidth: .infinity)
    }
    
    func fetchAndAddUserProfileURL(with uri: String, at index: Int) {
        spotify.api.userProfile(uri)
            .sink { completion in
                print(completion)
            } receiveValue: { user in
                self.imageURLs[index] = user.images?.first?.url
            }.store(in: &cancellables)

    }
}
