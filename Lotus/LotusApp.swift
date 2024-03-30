//
//  LotusApp.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/26/24.
//

import SwiftUI
import SwiftData
import SteadmanUI
import SpotifyWebAPI

@main
struct LotusApp: App {
    @ObservedObject var defaults = ObservableDefaults.shared
    @ObservedObject var screen = Screen.shared
    
    @StateObject private var spotify = Spotify()
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                NavigationStack {
                    ContentView()
                        .background(Color.background)
                        .environmentObject(screen)
                        .environmentObject(defaults)
                        .environmentObject(spotify)
                        .onAppear {
                            screen.width = geometry.size.width
                            screen.height = geometry.size.height
                            screen.safeAreaInsets = geometry.safeAreaInsets
                            screen.initialSafeAreaInsets = geometry.safeAreaInsets
                        }.onChange(of: geometry.size) { _, newValue in
                            screen.width = geometry.size.width
                            screen.height = geometry.size.height
                            screen.safeAreaInsets = geometry.safeAreaInsets
                        }
                }
            }
        }
//        .modelContainer(sharedModelContainer)
    }
}
