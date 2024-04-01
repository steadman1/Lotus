//
//  LoungeMostPlayed.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/31/24.
//

import SwiftUI
import SteadmanUI

struct LoungeMostPlayed: View {
    @EnvironmentObject var screen: Screen
    
    private let text = "Most Played"
    private let ratio: CGFloat = 42 / 318
    private let fontRatio: CGFloat = 55 / 42
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            var width = screen.width - Screen.padding * 2 - (screen.width - Screen.padding * 2) * ratio
            var fontSize = width * ratio * fontRatio
    
            HStack {
                Rectangle()
                    .frame(width: width, height: width)
                Spacer()
            }.padding(.horizontal, Screen.padding)
            HStack {
                VStack(spacing: 0) {
                    Text(text.uppercased())
                        .font(Font.custom("Newake", size: fontSize))
                        .foregroundStyle(Color.primaryText)
                        .rotationEffect(.degrees(270))
                }.frame(height: width)
                    .offset(x: text.uppercased().widthOfString(usingFont: UIFont(name: "Newake", size: fontSize)!) / 2 - Screen.padding)
                    .alignRight()
            }.padding(.trailing, Screen.padding)
        }.padding(.vertical, Screen.padding)
    }
}
