//
//  ExpandingText.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/31/24.
//

import Foundation
import SwiftUI
import SteadmanUI

struct ExpandingText: View {
    @EnvironmentObject var screen: Screen
    
    private let text: String
    private let font: Font
    private let textSize: CGSize
    
    init(_ text: String, font: Font = .sansNavigationHeader) {
        self.text = text
        self.font = font
        self.textSize = CGSize(width: text.widthOfString(usingFont: Font.uiSansNavigationHeader),
                               height: text.heightOfString(usingFont: Font.uiSansNavigationHeader))
    }
    
    var body: some View {
        let baseTracking: CGFloat = (screen.width - Screen.padding - textSize.width) / CGFloat(text.count)
        return GeometryReader { geometry in
            VStack {
                Text(text)
                    .font(font)
                    .foregroundStyle(Color.primaryText)
                    .tracking(baseTracking / CGFloat(text.count - 1) * CGFloat(text.count))
            }.frame(width: geometry.size.width)
        }.frame(height: textSize.height)
    }
}
