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
    
    var body: some View {
        ScrollView {
            Spacer().frame(height: Screen.padding)
            Extract {
                FriendActivityGreeting()
                    .alignLeft()
                
                FriendActivityCurrentlyListening()
            } views: { views in
                ForEach(Array(zip(views.indices, views)), id: \.0) { index, content in
                    content
                    
                    if index < views.count - 1 {
                        Divider()
                    }
                }
            }.withNavBarTheEnd()
        }
    }
}
