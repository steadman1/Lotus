//
//  Home.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/27/24.
//

import SwiftUI
import SteadmanUI

struct Home: View {
    @EnvironmentObject var defaults: ObservableDefaults
    @EnvironmentObject var screen: Screen
    
    @StateObject private var spotifyWebAPI = SpotifyWebAPI.shared
    
    @State private var scrollOffset: CGFloat = 0
    @State private var isSnapping = false
    @State private var sp_dc: String?
    @State private var friendActivity: SpotifyFriendActivity?
    @State private var refresh_sp_dc = false
    
    private let friendActivityHeight: CGFloat = 80
    private let stickyHeaderHeight: CGFloat = 60
    
    var body: some View {
        let stickyHeaderOffset = -screen.safeAreaInsets.top - friendActivityHeight + Screen.padding + 2
        ScrollViewReader { proxy in
            ScrollView {
                GeometryReader { geometry in
                    Color.white.opacity(0.000001)
                        .frame(height: 0)
                        .onAppear {
                            // Initialize the scroll offset based on the current geometry
                            self.scrollOffset = geometry.frame(in: .global).minY
                        }
                        .onChange(of: geometry.frame(in: .global).minY) { _, newValue in
                            // Update the scroll offset when the geometry changes
                            self.scrollOffset = newValue - screen.safeAreaInsets.top
                        }
                }.id("Top")
                
                VStack(spacing: 0) {
                    VStack {
                        if friendActivity != nil {
                            FriendActivity(friendActivity: friendActivity!)
                                .frame(height: friendActivityHeight)
                                .id("FriendActivity")
                        } else {
                            Spacer().frame(height: friendActivityHeight)
                        }
                    }.padding(.bottom, Screen.padding)
                        .offset(y: -scrollOffset)
                    
                    ZStack(alignment: .top) {
                        RoundedRectangle(cornerRadius: 32)
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .foregroundStyle(Color.white)
                            .offset(y: scrollOffset * 1 + (screen.safeAreaInsets.top - Screen.padding / screen.height))
                        
                        VStack {
                            EmptyView().id("BlankView")
                            
                            ZStack {
                                Text("Test")
                            }.frame(maxWidth: .infinity)
                                .frame(height: stickyHeaderHeight)
                                .background(Color.blue)
                                .offset(y: scrollOffset < stickyHeaderOffset ? -scrollOffset + stickyHeaderOffset : 0)
                                .zIndex(1)
                                .id("StickyHeader")
                            
                            Spacer().frame(height: Screen.padding)
                            
                            VStack {
                                ForEach(0..<100) { index in
                                    Text(String(index))
                                }
                            }.zIndex(0)
                        }.frame(maxWidth: .infinity)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .onAppear { proxy.scrollTo("BlankView", anchor: .top) }
            .onChange(of: (friendActivity != nil)) { _, _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation {
                        proxy.scrollTo("Top", anchor: .bottom)
                    }
                }
            }
            .onChange(of: scrollOffset) { _, newValue in
//                handleStickyHeaderSnap(newValue, proxy: proxy, offset: stickyHeaderOffset)
            }
        }.overlay(alignment: .top) {
            if scrollOffset < stickyHeaderOffset {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: screen.safeAreaInsets.top)
                    .background(Color.white)
                    .foregroundStyle(Color.white.opacity(0.000001))
                    .offset(y: -screen.safeAreaInsets.top)
                    .zIndex(0)
            }
        }
        .sheet(isPresented: $refresh_sp_dc) {
            CookieFinder(url: URL(string: "https://accounts.spotify.com/login")!,
                         cookieName: "sp_dc") { cookie in
                sp_dc = cookie.value
                defaults.sp_dc = cookie.value
            }
        }
        .onAppear { handleStored_sp_dc() }
        .onChange(of: sp_dc) { getFriendActivity($1) }
            
    }
    
    func handleStickyHeaderSnap(_ newValue: CGFloat, proxy: ScrollViewProxy, offset: CGFloat) {
        let snapPosition = friendActivityHeight - stickyHeaderHeight / 2 // Adjust based on your layout
        let snapThreshold: CGFloat = 100 // Adjust the threshold as needed
        
        print(newValue - snapPosition)
        
        if abs(newValue - offset) < 50 && abs(newValue - snapPosition) < snapThreshold && !isSnapping {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Minor delay for smoother animation
                isSnapping = true
                withAnimation {
                    proxy.scrollTo("StickyHeader", anchor: .top)
                }
            }
        }
        
        isSnapping = abs(newValue - offset) < 15
    }
    
    func handleRefresh_sp_dc(_ condition: Bool = true) {
        DispatchQueue.main.async { refresh_sp_dc = condition }
    }
    
    func handleStored_sp_dc() {
        guard let stored_sp_dc = defaults.sp_dc else {
            handleRefresh_sp_dc()
            return
        }
        
        DispatchQueue.main.async { sp_dc = stored_sp_dc }
    }
    
    func getFriendActivity(_ newValue: String?) {
        guard let newValue else {
            handleRefresh_sp_dc()
            return
        }
        
        let openSpotifyAPI = OpenSpotifyAPI()
        openSpotifyAPI.getWebAccessToken(spDcCookie: newValue) { accessToken in
            guard let accessToken = accessToken else { return }
            spotifyWebAPI.authenticate(accessToken: accessToken.accessToken)
            
            openSpotifyAPI.getFriendActivity(webAccessToken: accessToken.accessToken) { friendActivity in
                
                self.friendActivity = friendActivity
            }
        }
        handleRefresh_sp_dc(false)
    }
}

extension Animation {
    public static let lotusBounce: Animation = .interpolatingSpring(stiffness: 250, damping: 12).speed(1.2)
}
