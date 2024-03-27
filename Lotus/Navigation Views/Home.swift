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
    
    @StateObject var spotifyWebAPI = SpotifyWebAPI.shared
    
    @State var sp_dc: String?
    @State var friendActivity: SpotifyFriendActivity?
    @State var refresh_sp_dc = false
    
    var body: some View {
        VStack {
            if friendActivity != nil {
                FriendActivity(friendActivity: friendActivity!)
            }
        }.sheet(isPresented: $refresh_sp_dc) {
            CookieFinder(url: URL(string: "https://accounts.spotify.com/login")!,
                         cookieName: "sp_dc") { cookie in
                sp_dc = cookie.value
                defaults.sp_dc = cookie.value
            }
        }
        .onAppear { handleStored_sp_dc() }
        .onChange(of: sp_dc) { getFriendActivity($1) }
            
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
        openSpotifyAPI.getWebAccessToken(spDcCookie: newValue) { accessToken in
            guard let accessToken = accessToken else { return }
            spotifyWebAPI.authenticate(accessToken: accessToken.accessToken)
            
            openSpotifyAPI.getFriendActivity(webAccessToken: accessToken.accessToken) { friendActivity in
                
                self.friendActivity = friendActivity
            }
        }
        handleRefresh_sp_dc(false)
    }
}
