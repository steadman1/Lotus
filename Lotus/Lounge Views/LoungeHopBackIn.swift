//
//  LoungeHopBackIn.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/31/24.
//

import SwiftUI
import SteadmanUI
import ACarousel

struct Item: Identifiable {
    let id = UUID()
    let name: String
}

struct LoungeHopBackIn: View {
    @EnvironmentObject var screen: Screen
    
    private let count = 5
    private let text = "Hop Back In"
    private let items = [
        Item(name: "Test 1"),
        Item(name: "Test 2"),
        Item(name: "Test 3"),
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(text.uppercased())
                .font(.serifHeader)
                .foregroundStyle(Color.primaryText)
                .padding(.leading, Screen.padding)
            ACarousel(items, spacing: 0) { item in
                VStack {
                    Rectangle()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(Color.foreground)
                    Text(item.name)
                }
                
            }.frame(height: 300)
        }.padding(.vertical, Screen.padding)
    }
}
