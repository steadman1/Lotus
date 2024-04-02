//
//  Search.swift
//  Lotus
//
//  Created by Spencer Steadman on 4/2/24.
//

import SwiftUI
import SteadmanUI

struct Search: View {
    var body: some View {
        ScrollView {
            Spacer().frame(height: Screen.padding)
            Extract {
                SearchGreeting()
                    .alignLeft()
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
