//
//  ContentView.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/26/24.
//

import SwiftUI
import SteadmanUI

struct ContentView: View {
    @EnvironmentObject var defaults: ObservableDefaults
    @EnvironmentObject var screen: Screen
    
    let navigationItems = [
        NavigationItem(name: "Home",
                       from: Image(.house),
                       to: Image(.houseFill)),
        NavigationItem(name: "Search",
                       from: Image(.magnifyingglass),
                       to: Image(.magnifyingglassFill)),
        NavigationItem(name: "My Library",
                       from: Image(.records),
                       to: Image(.recordsFill)),
    ]
    
    var body: some View {
        CustomNavigationBar(items: navigationItems) {
            Home()
        }
    }
}

#Preview {
    ContentView()
}
