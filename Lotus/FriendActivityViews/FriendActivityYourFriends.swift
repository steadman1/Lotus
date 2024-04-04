//
//  FriendActivityYourFriends.swift
//  Lotus
//
//  Created by Spencer Steadman on 4/3/24.
//

import SwiftUI
import SteadmanUI
import Combine
import ActivityKit

struct FriendActivityYourFriends: View {
    @EnvironmentObject var screen: Screen
    @EnvironmentObject var defaults: ObservableDefaults
    @EnvironmentObject var spotify: Spotify
    
    @Binding var friendActivity: SpotifyFriendActivity?
    
    @State var tunedInIndex = -1
    
    private let containerHeight: CGFloat = 120
    
    var body: some View {
        VStack(spacing: Screen.padding) {
            if friendActivity != nil && !friendActivity!.friends.isEmpty {
                ForEach(Array(zip(friendActivity!.friends.indices, friendActivity!.friends)), id: \.0) { index, friend in
                    YourFriendContainer(tunedIn: $tunedInIndex, friend: friend, index: index)
                        .frame(width: screen.width - Screen.padding * 2, height: containerHeight)
                }
            }
            
        }.padding(.vertical, Screen.padding)
    }
}

struct YourFriendContainer: View {
    @EnvironmentObject var screen: Screen
    @EnvironmentObject var spotify: Spotify
    
    @ObservedObject var imageLoader = ImageLoader()
    
    @Binding var tunedIn: Int
    
    @State var animation: CGFloat = 0
    @State var profileURL: URL? = nil
    @State var activity: Activity<LiveFriendActivityAttributes>?
    @State var cancellables = Set<AnyCancellable>()
    
    let friend: Friend
    let index: Int
    
    private let profileSize: CGFloat = 32
    private let buttonSize: CGFloat = 48
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .foregroundStyle(Color.background)
                    .border(Color.foreground, width: 1)
                HStack(alignment: .top, spacing: Screen.halfPadding / 2) {
                    HStack {
                        if profileURL != nil {
                            AsyncImage(url: profileURL) { phase in
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
                        
                        Image(.sun)
                            .resizable()
                            .frame(width: 10, height: 10)
                            .foregroundStyle(Color.foreground)
                        
                        Text(friend.user.name.uppercased())
                            .lineLimit(1)
                            .font(.sansSubtitle)
                            .foregroundStyle(Color.primaryText)
                    }.padding([.bottom, .trailing], Screen.halfPadding)
                        .background(Color.background)
                    
                    Spacer()
                    
                    HStack {
                        HStack(spacing: Screen.halfPadding) {
                            Button {
                                if tunedIn == index {
                                    Task {
                                        await self.activity?.end(dismissalPolicy: .immediate)
                                        self.activity = nil
                                    }
                                    
                                    tunedIn = -1
                                } else {
                                    imageLoader.loadImages(profileURL: profileURL,
                                                           trackURL: friend.track.imageUrl.convertToHTTPS()) { profile, track in
                                        print(profile, track)
                                        requestLiveActivity(profile, track)
                                    }
                                    
                                    tunedIn = index
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .stroke(Color.foreground, lineWidth: 1)
                                    Circle()
                                        .foregroundStyle(Color.foreground)
                                        .opacity(animation)
                                        .animation(.snappy, value: tunedIn)
                                    ZStack {
                                        Image(.eyeClosed)
                                            .font(.serifBody)
                                            .foregroundStyle(Color.background)
                                            .animation(.snappy, value: tunedIn)
                                            .offset(y: buttonSize * -(1 - animation))
                                        Image(.eye)
                                            .font(.serifBody)
                                            .foregroundStyle(Color.foreground)
                                            .offset(y: buttonSize * animation)
                                    }.frame(width: buttonSize, height: buttonSize)
                                        .clipShape(Circle())
                                }.frame(width: buttonSize, height: buttonSize)
                            }
                            ZStack {
                                Circle()
                                    .stroke(Color.foreground, lineWidth: 1)
                                Image(systemName: "ellipsis")
                                    .font(.serifBody)
                                    .foregroundStyle(Color.foreground)
                            }.frame(width: buttonSize, height: buttonSize)
                        }
                    }.padding([.top, .horizontal], 1)
                        .padding([.bottom, .leading], Screen.halfPadding)
                        .background(Color.background)
                }
                
                let imageHeight = geometry.size.height - Screen.halfPadding * 2 - profileSize
                HStack(spacing: Screen.halfPadding) {
                    AsyncImage(url: friend.track.imageUrl.convertToHTTPS()) { phase in
                        ZStack {
                            Rectangle()
                                .frame(width: imageHeight, height: imageHeight)
                                .foregroundStyle(Color.foreground)
                            
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .frame(width: imageHeight, height: imageHeight)
                                    .background(Color.background)
                                    .transition(.opacity.animation(.snappy()))
                            default:
                                EmptyView()
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text(friend.track.name)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .font(.serifBody)
                            .fontWeight(.medium)
                        Text(friend.track.artist.name)
                            .lineLimit(1)
                            .font(.serifCaption)
                    }
                    
                    Spacer()
                    
                    Text(Date(timeIntervalSince1970: Double(friend.timestamp) / 1000).timeAgo())
                        .font(.serifCaption)
                        .foregroundStyle(Color.primaryText)
                        .padding(.trailing, Screen.halfPadding)
                }.padding(.horizontal, Screen.halfPadding)
                    .frame(width: geometry.size.width)
                    .offset(y: profileSize + Screen.halfPadding)
                
            }.frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                .onChange(of: tunedIn) { withAnimation(.snappy) { animation = tunedIn == index ? 1 : 0 } }
                .onAppear {
                    fetchAndAddUserProfileURL(with: friend.user.uri)
                }
        }
    }
    
    func fetchAndAddUserProfileURL(with uri: String) {
        spotify.api.userProfile(uri)
            .sink { completion in
                print(completion)
            } receiveValue: { user in
                self.profileURL = user.images?.first?.url
            }.store(in: &cancellables)

    }
    
    func requestLiveActivity(_ profileImageData: Data, _ trackImageData: Data) {
        let attributes = LiveFriendActivityAttributes(profileData: profileImageData,
                                                      name: friend.user.name)
        let initialState = LiveFriendActivityAttributes.ContentState(trackName: friend.track.name,
                                                                     trackArtist: friend.track.artist.name,
                                                                     trackImageData: trackImageData,
                                                                     timestamp: TimeInterval(friend.timestamp / 1000),
                                                                     isSaved: false)
        let content = ActivityContent(state: initialState, staleDate: nil, relevanceScore: 1.0)

        do {
            self.activity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            print(error.localizedDescription)
        }
    }
}
