//
//  PlaylistView.swift
//  Lotus
//
//  Created by Spencer Steadman on 4/10/24.
//

import SwiftUI
import SteadmanUI
import SpotifyWebAPI
import Combine

struct PlaylistView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var screen: Screen
    @EnvironmentObject var spotify: Spotify
    
    @State private var playlist: Playlist<PagingObject<PlaylistItemContainer<PlaylistItem>>>? = nil
    @State private var scrollOffset: CGFloat = 0
    @State private var cancellables = Set<AnyCancellable>()
    
    var playlistURI: SpotifyURIConvertible
    
    var body: some View {
        GeometryReader { outerGeometry in
            VStack {
                DismissBar(playlist?.name ?? "", presentation: .page)
                
                ScrollView {
                    VStack(spacing: Screen.halfPadding) {
                        GeometryReader { innerGeometry in
                            Color.background // Invisible view, just to calculate the offset
                                .frame(height: 2000) // Arbitrary large height for the content to enable scrolling
                                .onAppear {
                                    // Calculate initial offset
                                    scrollOffset = innerGeometry.frame(in: .global).minY - outerGeometry.frame(in: .global).minY
                                }
                                .onChange(of: innerGeometry.frame(in: .global).minY) { _, newValue in
                                    // Update offset when the user scrolls
                                    scrollOffset = newValue - outerGeometry.frame(in: .global).minY
                                }
                        }
                        let coverHeight = min(screen.width / 2 + max(scrollOffset, 0) * 0.3, screen.width - Screen.padding * 2)
                        ZStack {
                            AsyncImage(url: playlist?.images?.last?.url.convertToHTTPS()) { phase in
                                ZStack {
                                    Rectangle()
                                        .stroke(Color.foreground, lineWidth: 1)
                                        .frame(width: coverHeight - 2, height: coverHeight - 2)
                                    
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .frame(width: coverHeight * 1.1, height: coverHeight * 1.1)
                                            .clipShape(RoundedRectangle(cornerRadius: 32))
                                            .blur(radius: 14)
                                            .opacity(0.4)
                                            .transition(.opacity.animation(.snappy()))
                                    default:
                                        EmptyView()
                                    }
                                }
                            }
                            AsyncImage(url: playlist?.images?.first?.url.convertToHTTPS()) { phase in
                                ZStack {
                                    Rectangle()
                                        .stroke(Color.foreground, lineWidth: 1)
                                        .frame(width: coverHeight - 2, height: coverHeight - 2)
                                    
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .frame(width: coverHeight, height: coverHeight)
                                            .background(Color.background)
                                            .transition(.opacity.animation(.snappy()))
                                    default:
                                        EmptyView()
                                    }
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .navigationBarBackButtonHidden(true)
            .onAppear { fetchPlaylist() }
    }
    
    func fetchPlaylist() {
        spotify.api.playlist(playlistURI)
            .sink { completion in
                print(completion)
            } receiveValue: { result in
                self.playlist = result
            }.store(in: &cancellables)

    }
}
