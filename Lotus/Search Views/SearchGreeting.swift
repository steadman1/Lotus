//
//  SearchGreeting.swift
//  Lotus
//
//  Created by Spencer Steadman on 4/2/24.
//

import SwiftUI
import SteadmanUI

struct SearchGreeting: View {
    @EnvironmentObject var screen: Screen
    
    private let text = "What Do You\nWant To Play?"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(text.uppercased())
                .font(.serifHeader)
                .foregroundStyle(Color.primaryText)
        }.padding(.horizontal, Screen.padding)
    }
}
