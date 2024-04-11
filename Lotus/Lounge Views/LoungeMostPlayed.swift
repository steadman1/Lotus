//
//  LoungeMostPlayed.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/31/24.
//

import SwiftUI
import Combine
import SteadmanUI
import SpotifyWebAPI

struct LoungeMostPlayed: View {
    @EnvironmentObject var screen: Screen
    @EnvironmentObject var spotify: Spotify
    
    @State private var animation: CGFloat = 0
    @State private var album: SpotifyWebAPI.Album? = nil
    @State private var cancellables: Set<AnyCancellable> = []
    
    private let text = "Most Played"
    private let ratio: CGFloat = 42 / 318
    private let fontRatio: CGFloat = 55 / 42

    private let width: CGFloat
    private let fontSize: CGFloat
    private let textOffset: CGFloat
    
    init() {
        self.width = Screen.shared.width - Screen.padding * 2 - (Screen.shared.width - Screen.padding * 2) * self.ratio
        self.fontSize = width * ratio * fontRatio
        self.textOffset = self.text.uppercased().widthOfString(usingFont: UIFont(name: "Newake", size: self.fontSize)!) / 2 - Screen.padding
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            HStack {
                AsyncImage(url: album?.images?.first?.url) { phase in
                    ZStack {
                        Rectangle()
                            .stroke(Color.foreground, lineWidth: 1)
                            .frame(width: width - 2, height: width - 2)
                        
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: width, height: width)
                                .background(Color.foreground)
                                .transition(.opacity.animation(.snappy()))
                        default:
                            EmptyView()
                        }
                    }
                }.offset(x: -screen.width * (1 - animation))
                
                Spacer()
            }.padding(.horizontal, Screen.padding)
            
            HStack {
                VStack(spacing: 0) {
                    Text(text.uppercased())
                        .font(Font.custom("Newake", size: fontSize))
                        .foregroundStyle(Color.primaryText)
                        .rotationEffect(.degrees(270))
                }.frame(height: width)
                    .offset(x: textOffset + textOffset * (1 - animation))
                    .alignRight()
            }.padding(.trailing, Screen.padding)
        }.padding(.vertical, Screen.padding)
            .onAppear { fetchAndSetTopAlbum() }
            .onChange(of: self.album) { _, newValue in
                withAnimation(.snappy) {
                    self.animation = newValue != nil ? 1 : 0
                }
            }
    }
    
    func fetchAndSetTopAlbum() {
        let currentDate = Date()
        let fourteenDaysAgo = Calendar.current.date(byAdding: .day, value: -14, to: currentDate)!
        spotify.api.recentlyPlayed(.after(fourteenDaysAgo), limit: 50)
            .sink { completion in
                // print(completion)
            } receiveValue: { results in
                self.album = calculateMostFrequentAlbum(history: results.items)
            }.store(in: &cancellables)
    }
    
    func calculateMostFrequentAlbum(history: [PlayHistory]) -> SpotifyWebAPI.Album? {
        var albums: [String: AlbumWithCount] = [:]
        
        for item in history {
            guard let album = item.track.album, let id = album.uri else {
                continue
            }
            
            if let _ = albums[id] { albums[id]!.count += 1 }
            else { albums[id] = AlbumWithCount(album: album) }
        }
        
        if !albums.isEmpty {
            let keys = Array(albums.keys.sorted())
            var max = 0
            var key = keys[0]
            
            for iterKey in keys {
                if albums[iterKey]!.count > max { max = albums[iterKey]!.count; key = iterKey }
            }
            
            return albums[key]!.album
        }
        return nil
    }
    
    struct AlbumWithCount {
        let album: SpotifyWebAPI.Album
        var count: Int = 0
    }
}
