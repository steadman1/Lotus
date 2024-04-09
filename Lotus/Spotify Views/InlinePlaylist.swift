//
//  Spotify Views.swift
//  Lotus
//
//  Created by Spencer Steadman on 4/9/24.
//

import SwiftUI
import SpotifyWebAPI
import SteadmanUI

struct InlinePlaylist: View {
    var item: Playlist<PlaylistItemsReference>
    var itemHeight: CGFloat = 104
    
    var body: some View {
        HStack {
            AsyncImage(url: item.images?.first?.url.convertToHTTPS()) { phase in
                ZStack {
                    Rectangle()
                        .frame(width: itemHeight, height: itemHeight)
                        .foregroundStyle(Color.foreground)
                    
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: itemHeight, height: itemHeight)
                            .background(Color.background)
                            .transition(.opacity.animation(.snappy()))
                    default:
                        EmptyView()
                    }
                }
            }
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .lineLimit(2)
                    .font(.sansSubtitle)
                    .foregroundStyle(Color.foreground)
                Text(item.owner?.displayName ?? "Unknown")
                    .font(.serifBody)
                    .foregroundStyle(Color.foreground)
            }.padding(.leading, Screen.halfPadding)
        }
    }
}

