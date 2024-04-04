//
//  FriendActivity.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/27/24.
//

import SwiftUI
import SteadmanUI

struct FriendActivity: View {
    @EnvironmentObject var spotify: Spotify
    
    @State var friendActivity: SpotifyFriendActivity?
    
    @State var timer: Timer? = nil
    
    var body: some View {
        ScrollView {
            Spacer().frame(height: Screen.padding)
            Extract {
                FriendActivityGreeting()
                    .alignLeft()
                
                FriendActivityCurrentlyListening(friendActivity: $friendActivity)
                
                FriendActivityYourFriends(friendActivity: $friendActivity)
            } views: { views in
                ForEach(Array(zip(views.indices, views)), id: \.0) { index, content in
                    content
                    
                    if index < views.count - 1 {
                        Divider()
                    }
                }
            }.withNavBarTheEnd()
        }.onAppear {
            spotify.open_api.fetchFriendActivity { result in
                self.friendActivity = result
            }
            
            self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(20), repeats: true) { timer in
                spotify.open_api.fetchFriendActivity { result in
                    self.friendActivity = result
                }
            }
        }
    }
}
