//
//  LibraryPlaylists.swift
//  Lotus
//
//  Created by Spencer Steadman on 4/8/24.
//

import SwiftUI
import SpotifyWebAPI
import Combine
import SwiftData
import SteadmanUI

struct LibraryPlaylists: View {
    @Environment(\.modelContext) var context
    @EnvironmentObject var screen: Screen
    @EnvironmentObject var spotify: Spotify
    
    @Binding var scrollOffset: CGFloat
    
    @State var playlists: [[Playlist<PlaylistItemsReference>]] = []
    @State var cancellables = Set<AnyCancellable>()
    
    @Query var pinItems: [PinItem]
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: Screen.halfPadding) {
            if !playlists.isEmpty {
                ForEach(Array(zip(playlists.indices, playlists)), id: \.0) { index, playlist in
                    LibraryPlaylistsBatch(scrollOffset: $scrollOffset, items: playlist, batch: index * 20)
                }
            }
        }.transition(.scale.animation(.snappy))
            .onAppear { fetchCurrentUserPlaylists() }
    }
    
    func fetchCurrentUserPlaylists(limit: Int = 20, offset: Int = 0) {
        spotify.api.currentUserPlaylists(limit: limit, offset: offset)
            .sink { completion in
                print(completion)
            } receiveValue: { result in
                playlists.append(result.items)
                
                if result.next != nil {
                    fetchCurrentUserPlaylists(offset: offset + limit)
                }
            }.store(in: &cancellables)
    }

    func addPinItem(_ item: PinItem) {
        context.insert(item)
        
        save()
    }

    func removePinItem(_ item: PinItem) {
        context.delete(item)
        
        save()
    }
    
    func save() {
        try? context.save()
    }
}

struct LibraryPlaylistsBatch: View {
    @EnvironmentObject var screen: Screen
    @EnvironmentObject var spotify: Spotify
    
    @Binding var scrollOffset: CGFloat
    
    @State var isNavigating = false
    @State var slideUpAnimation: CGFloat = 0
    
    var items: [Playlist<PlaylistItemsReference>]
    var batch: Int
    
    private let buttonSize: CGFloat = 40
    private let itemHeight: CGFloat = 104
    
    var body: some View {
        ForEach(Array(zip(items.indices, items)), id: \.0) { index, playlist in
            HStack(spacing: Screen.halfPadding / 2) {
                InlinePlaylist(item: playlist)
                    .frame(height: itemHeight)
                    .padding(.horizontal, Screen.halfPadding)
                    .transition(.opacity.animation(.snappy))
                Spacer()
                NavigationLink {
                    PlaylistView(playlistURI: playlist.uri)
                        .environmentObject(screen)
                        .environmentObject(spotify)
                } label: {
                    ZStack {
                        Circle()
                            .stroke(Color.foreground, lineWidth: 1)
                        Image(.outArrow)
                            .font(.icon40)
                            .foregroundStyle(Color.foreground)
                    }.frame(width: buttonSize, height: buttonSize)
                        .padding(.trailing, Screen.halfPadding)
                        .offset(x: 1)
                }.offset(x: (buttonSize + Screen.halfPadding) - calculateButtonOffset(index: index + batch))
                    .animation(Animation.snappy(extraBounce: 0.3), value: calculateButtonOffset(index: index + batch))
            }.id(playlist.id + String(index + batch))
                .offset(y: 100 * CGFloat(index + batch + 1) * (1 - slideUpAnimation))
//                .onTapGesture { isNavigating = true }
//                .navigationDestination(isPresented: $isNavigating) { PlaylistView(playlist: playlist) }
                .onAppear {
                    withAnimation(.snappy) {
                        self.slideUpAnimation = 1
                    }
                }
        }
    }
    
    private func calculateItemOffset(index: Int) -> CGFloat {
            return 100 * CGFloat(index + 1) * (1 - slideUpAnimation)
        }
        
    // Dynamically calculate button's x-offset based on scrollOffset and centering logic
    private func calculateButtonOffset(index: Int) -> CGFloat {
        // Calculate the "focus" position based on scroll offset and other factors
        let focusPosition = scrollOffset - 100 + CGFloat(index) * (itemHeight + Screen.halfPadding)
        
        return focusPosition > -screen.height / 2 && focusPosition < screen.height / 2
                    ? (buttonSize + Screen.halfPadding)
                    : 0
    }
}
