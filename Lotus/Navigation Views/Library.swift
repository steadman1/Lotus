//
//  MyLibrary.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/27/24.
//

import SwiftUI
import SteadmanUI

struct Library: View {
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { outerGeometry in
            ScrollView {
                GeometryReader { innerGeometry in
                    Color.background // Invisible view, just to calculate the offset
                        .onAppear {
                            // Calculate initial offset
                            scrollOffset = innerGeometry.frame(in: .global).minY - outerGeometry.frame(in: .global).minY
                        }
                        .onChange(of: innerGeometry.frame(in: .global).minY) { _, newValue in
                            // Update offset when the user scrolls
                            scrollOffset = newValue - outerGeometry.frame(in: .global).minY
                        }
                }.frame(height: 1)
                    .offset(y: -9)
                Extract {
                    LibraryGreeting()
                        .alignLeft()
                    
                    LibraryPlaylists(scrollOffset: $scrollOffset)
                    
                } views: { views in
                    ForEach(Array(zip(views.indices, views)), id: \.0) { index, content in
                        content
                        
                        if index < views.count - 1 {
                            Divider()
                        } else {
                            Spacer().frame(height: Screen.padding)
                        }
                    }
                }.withNavBarTheEnd()
                
            }
        }
    }
}
