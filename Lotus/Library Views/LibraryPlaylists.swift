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
    @EnvironmentObject var spotify: Spotify
    
    @State var playlists: [Playlist<PlaylistItemsReference>] = []
    @State var cancellables = Set<AnyCancellable>()
    @State var animation: CGFloat = 0
    
    @Query var pinItems: [PinItem]
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: Screen.halfPadding) {
            if !playlists.isEmpty {
                ForEach(Array(zip(playlists.indices, playlists)), id: \.0) { index, playlist in
                    InlinePlaylist(item: playlist)
                        .padding(.horizontal, Screen.halfPadding)
                        .transition(.opacity.animation(.snappy))
                        .offset(y: 100 * CGFloat(index + 1) * (1 - animation))
                }
            }
        }.onAppear { fetchCurrentUserPlaylists() }
    }
    
    func fetchCurrentUserPlaylists(offset: Int = 0) {
        spotify.api.currentUserPlaylists(limit: 50, offset: offset)
            .sink { completion in
                print(completion)
            } receiveValue: { result in
                playlists.append(contentsOf: result.items)
                
                if result.next != nil {
                    fetchCurrentUserPlaylists(offset: offset + 50)
                } else {
                    print("done playlists")
                    withAnimation(.snappy) {
                        self.animation = 1
                    }
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
