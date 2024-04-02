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
        NavigationItem(name: "Lounge",
                       from: Image(.house),
                       to: Image(.houseFill)),
        NavigationItem(name: "Friends",
                       from: Image(.magnifyingglass),
                       to: Image(.magnifyingglassFill)),
        NavigationItem(name: "Search",
                       from: Image(.magnifyingglass),
                       to: Image(.magnifyingglassFill)),
        NavigationItem(name: "Library",
                       from: Image(.records),
                       to: Image(.recordsFill)),
    ]
    
    var body: some View {
        CustomNavigationBar(items: navigationItems) {
            Home()
            FriendActivity()
            Search()
            Library()
        }
    }
}
