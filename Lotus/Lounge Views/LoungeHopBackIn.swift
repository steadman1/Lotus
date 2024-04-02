//
//  LoungeHopBackIn.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/31/24.
//

import SwiftUI
import Combine
import SteadmanUI
import SpotifyWebAPI

struct LoungeHopBackIn: View {
    @EnvironmentObject var screen: Screen
    @EnvironmentObject var spotify: Spotify
    
    @State private var playlists: [SpotifyWebAPI.Playlist<PlaylistItemsReference>] = []
    @State private var cancellables = Set<AnyCancellable>()
    
    private let itemSize: CGFloat = 144
    private let text = "Hop Back In"
    
    var body: some View {
        VStack(alignment: .leading, spacing: Screen.halfPadding) {
            Text(text.uppercased())
                .font(.serifHeader)
                .foregroundStyle(Color.primaryText)
                .padding(.leading, Screen.padding)
            if !playlists.isEmpty {
                PlaylistCarousel(items: playlists, itemSize: itemSize)
            } else {
                BlankCarousel(itemSize: itemSize)
            }
        }.padding(.vertical, Screen.padding)
            .onAppear { fetchAndSetRecentPlaylists() }
    }
    
    func fetchAndSetRecentPlaylists() {
        spotify.api.currentUserPlaylists(limit: 12)
            .sink { completion in
                print(completion)
            } receiveValue: { results in
                print(results)
                self.playlists = results.items
            }.store(in: &cancellables)
    }
}

struct PlaylistCarousel: View {
    
    let items: [SpotifyWebAPI.Playlist<PlaylistItemsReference>]
    let itemSize: CGFloat
    
    private let returnButtonSize: CGFloat = 48
    
    var body: some View {
        ZStack(alignment: .top) {
            ACarousel(items, itemWidth: itemSize, spacing: 0, headspace: 0) { item in
                VStack(spacing: Screen.halfPadding) {
                    AsyncImage(url: item.images.first?.url) { phase in
                        ZStack {
                            Rectangle()
                                .frame(width: itemSize, height: itemSize)
                                .background(Color.foreground)
                            
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
                    VStack {
                        Text(item.name)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .font(.sansBody)
                        Text("by " + (item.owner?.displayName ?? "unknown"))
                            .lineLimit(2)
                            .font(.serifBody)
                    }.padding(.horizontal, Screen.halfPadding / 2)
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
            }.frame(height: itemSize + Screen.padding + "|\n|".heightOfString(usingFont: Font.uiSansBody)
                    + "|".heightOfString(usingFont: Font.uiSerifBody)) // tall characters
        }.frame(maxWidth: .infinity)
    }
}

struct BlankCarousel: View {
    
    let itemSize: CGFloat
    private let blankItems = [BlankItem(), BlankItem(), BlankItem(), BlankItem(), BlankItem()]
    
    var body: some View {
        VStack {
            ACarousel(blankItems, itemWidth: itemSize, spacing: 0, headspace: 0) { item in
                VStack(spacing: Screen.halfPadding) {
                    Rectangle()
                        .foregroundStyle(Color.foreground)
                        .frame(width: itemSize, height: itemSize)
                }
            } returnView: { }
                .disabled(true)
            
            Spacer()
        }.frame(height: itemSize + Screen.padding + "|\n|".heightOfString(usingFont: Font.uiSansBody)
                + "|".heightOfString(usingFont: Font.uiSerifBody)) // tall characters
            .frame(maxWidth: .infinity)
    }
    
    struct BlankItem: Identifiable {
        var id: UUID
        
        init() {
            self.id = UUID()
        }
    }
}
