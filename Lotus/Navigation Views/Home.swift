//
//  Home.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/27/24.
//

import SwiftUI
import SteadmanUI
import SpotifyWebAPI
import Combine

struct Home: View {
    @EnvironmentObject var defaults: ObservableDefaults
    @EnvironmentObject var screen: Screen
    @EnvironmentObject var spotify: Spotify
    
    @StateObject private var openSpotifyAPI = OpenSpotifyAPI.shared
    
    @State private var refreshAuthorization = false
    @State private var cancellables = Set<AnyCancellable>()
    @State private var refreshID = UUID()
    
    private let friendActivityHeight: CGFloat = 80
    private let stickyHeaderHeight: CGFloat = 60
    
    var body: some View {
        ScrollView {
            Spacer().frame(height: Screen.padding)
            Extract {
                LoungeGreeting()
                    .alignLeft()
                
                LoungeMostPlayed()
                
                LoungeHopBackIn()
            } views: { views in
                ForEach(Array(zip(views.indices, views)), id: \.0) { index, content in
                    content
                    
                    if index < views.count - 1 {
                        Divider()
                    }
                }
            }.withNavBarTheEnd()
            
        }
        .id(refreshID)
        .sheet(isPresented: $refreshAuthorization) {
            RefreshAuthorization()
        }

        .onChange(of: spotify.isAuthorized) { print("test"); refreshID = UUID() }
        .onAppear {
            printSystemFonts()
            // try? self.spotify.keychain.remove(self.spotify.authorizationManagerKey)
            handleRefreshAuthorization(!spotify.api.authorizationManager.isAuthorized())
        }
    }
    
    private func calculateNavBarPadding() -> CGFloat {
        let text = "Library"
        let padding = text.heightOfString(usingFont: Font.uiSerifBody) +
        text.heightOfString(usingFont: Font.uiSerifHeader) + Screen.padding
        
        return padding
    }

    func printSystemFonts() {
        // Use this identifier to filter out the system fonts in the logs.
        let identifier: String = "[SYSTEM FONTS]"
        // Here's the functionality that prints all the system fonts.
        for family in UIFont.familyNames as [String] {
            debugPrint("\(identifier) FONT FAMILY :  \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                debugPrint("\(identifier) FONT NAME :  \(name)")
            }
        }
    }
    
    func handleRefreshAuthorization(_ condition: Bool = true) {
        DispatchQueue.main.async { refreshAuthorization = condition }
    }
}
