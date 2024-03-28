//
//  FriendActivity.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/27/24.
//

import SwiftUI
import SteadmanUI

struct FriendActivity: View {
    @State var friendActivity: SpotifyFriendActivity?
    
    let openSpotifyAPI = OpenSpotifyAPI.shared
    let spotifyWebAPI = SpotifyWebAPI.shared
    
    var body: some View {
        VStack {
            
        }.onAppear {
            openSpotifyAPI.getFriendActivity() { friendActivity in
                
                self.friendActivity = friendActivity
            }
        }
    }
}
