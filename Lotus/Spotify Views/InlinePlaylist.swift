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
    @EnvironmentObject var spotify: Spotify

    var item: Playlist<PlaylistItemsReference>
    
    var body: some View {
        GeometryReader { geometry in
            let itemHeight = geometry.size.height
            HStack {
                AsyncImage(url: item.images?.first?.url.convertToHTTPS()) { phase in
                    ZStack {
                        Rectangle()
                            .stroke(Color.foreground, lineWidth: 1)
                            .frame(width: itemHeight - 2, height: itemHeight - 2)
                        
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
                    Text("\(item.items.total) songs • by \(item.owner?.displayName ?? "Unknown")")
                        .font(.serifBody)
                        .foregroundStyle(Color.foreground)
                }.padding(.leading, Screen.halfPadding)
            }
        }
    }
}

