//
//  Home.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/27/24.
//

import SwiftUI
import SteadmanUI

struct Home: View {
    @EnvironmentObject var defaults: ObservableDefaults
    @EnvironmentObject var screen: Screen
    
    @StateObject private var openSpotifyAPI = OpenSpotifyAPI.shared
    @StateObject private var spotifyWebAPI = SpotifyWebAPI.shared
    
    @State private var isSnapping = false
    @State private var sp_dc: String?
    @State private var refresh_sp_dc = false
    
    private let friendActivityHeight: CGFloat = 80
    private let stickyHeaderHeight: CGFloat = 60
    
    var body: some View {
        VStack {
            Text("SUMMER")
                .font(.serifTitle)
            Text("STORIES")
                .font(.serifTitleItalic)
            Text("MENU TEST")
                .font(.sansOperator)
            Text("Lorem Ipsum")
                .font(.serifBody)
        }
        .sheet(isPresented: $refresh_sp_dc) {
            CookieFinder(url: URL(string: "https://accounts.spotify.com/login")!,
                         cookieName: "sp_dc") { cookie in
                sp_dc = cookie.value
                defaults.sp_dc = cookie.value
            }
        }
        .onAppear { printSystemFonts() }
        .onAppear { handleStored_sp_dc() }
        .onChange(of: sp_dc) { getFriendActivity($1) }
        .onChange(of: openSpotifyAPI.isAuthenticated) { _, newValue in
            switch newValue {
            case .success:
                spotifyWebAPI.authenticate(accessToken: openSpotifyAPI.accessToken!)
            default:
                return
            }
        }
            
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
    
    func handleRefresh_sp_dc(_ condition: Bool = true) {
        DispatchQueue.main.async { refresh_sp_dc = condition }
    }
    
    func handleStored_sp_dc() {
        guard let stored_sp_dc = defaults.sp_dc else {
            handleRefresh_sp_dc()
            return
        }
        
        DispatchQueue.main.async { sp_dc = stored_sp_dc }
    }
    
    func getFriendActivity(_ newValue: String?) {
        guard let newValue else {
            handleRefresh_sp_dc()
            return
        }
        
        let openSpotifyAPI = OpenSpotifyAPI()
        openSpotifyAPI.authenticate(spDcCookie: newValue)
        handleRefresh_sp_dc(false)
    }
}

extension Animation {
    public static let lotusBounce: Animation = .interpolatingSpring(stiffness: 250, damping: 12).speed(1.2)
}
