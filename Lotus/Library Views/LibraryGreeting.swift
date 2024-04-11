//
//  LibraryGreeting.swift
//  Lotus
//
//  Created by Spencer Steadman on 4/2/24.
//

import SwiftUI
import SteadmanUI

struct LibraryGreeting: View {
    @EnvironmentObject var screen: Screen
    
    @State private var isAddingItem = false
    
    private let text = "Your\nLibrary"
    private let buttonSize: CGFloat = 48
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(text.uppercased())
                    .font(.serifHeader)
                    .foregroundStyle(Color.primaryText)
                Spacer()
                HStack(spacing: Screen.halfPadding) {
                    ZStack {
                        Circle()
                            .stroke(Color.foreground, lineWidth: 1)
                        Image(.plus)
                            .font(.serifBody)
                            .foregroundStyle(Color.foreground)
                    }.frame(width: buttonSize, height: buttonSize)
                    ZStack {
                        Circle()
                            .stroke(Color.foreground, lineWidth: 1)
                        Image(.magnifyingglass)
                            .font(.serifBody)
                            .foregroundStyle(Color.foreground)
                    }.frame(width: buttonSize, height: buttonSize)
                }
            }
        }.padding(.horizontal, Screen.padding)
    }
}
