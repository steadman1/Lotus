//
//  FriendActivityGreeting.swift
//  Lotus
//
//  Created by Spencer Steadman on 4/2/24.
//

import SwiftUI
import SteadmanUI

struct FriendActivityGreeting: View {
    @EnvironmentObject var screen: Screen
    
    private let text = "Currently\nListening"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(text.uppercased())
                .font(.serifHeader)
                .foregroundStyle(Color.primaryText)
        }.padding(.horizontal, Screen.padding)
    }
}
