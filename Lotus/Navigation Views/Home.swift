//
//  Home.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/27/24.
//

import SwiftUI
import SteadmanUI
import SpotifyWebAPI
import Combine

struct Home: View {
    @EnvironmentObject var defaults: ObservableDefaults
    @EnvironmentObject var screen: Screen
    @EnvironmentObject var spotify: Spotify
    
    @StateObject private var openSpotifyAPI = OpenSpotifyAPI.shared
    
    @State private var alert: AlertItem? = nil
    @State private var sp_dc: String?
    @State private var refreshAuthorization = false
    @State private var authorizationURL: URL?
    
    @State private var cancellables = Set<AnyCancellable>()
    
    private let friendActivityHeight: CGFloat = 80
    private let stickyHeaderHeight: CGFloat = 60
    
    var body: some View {
        ScrollView {
            Spacer().frame(height: Screen.padding)
            VStack(alignment: .leading) {
                LoungeGreeting()
                    .alignLeft()
                
                LoungeMostPlayed()
                
                LoungeHopBackIn()
            }.withNavBarPadding()
                .withNavBarPadding()
                .withNavBarPadding()
            
        }
        .alert(item: $alert) { alert in
            Alert(title: alert.title, message: alert.message)
        }
        .sheet(isPresented: $refreshAuthorization) {
            CookieFinder(url: authorizationURL!, cookieName: "sp_dc") { cookie in
                print(cookie.value)
                sp_dc = cookie.value
                defaults.sp_dc = cookie.value
            } onIncomingURL: { url in
                handleAuthorizationURLWithQuery(url)
                handleRefreshAuthorization(false)
            }
        }
        //.onAppear { printSystemFonts() }
        //.onAppear { handleStored_sp_dc() }
        .onAppear {
            self.authorizationURL = spotify.fetchAuthorizationURL()
            handleRefreshAuthorization(!spotify.api.authorizationManager.isAuthorized())
        }
        //.onChange(of: sp_dc) { getFriendActivity($1) }
    }
    
    private func calculateNavBarPadding() -> CGFloat {
        let text = "Library"
        let padding = text.heightOfString(usingFont: UIFont(name: "TimesNewRomanMTStd-Cond", size: 16)!) +
            text.heightOfString(usingFont: UIFont(name: "Newake", size: 98)!) + Screen.padding
        
        return padding
    }

    func printSystemFonts() {
        // Use this identifier to filter out the system fonts in the logs.
        let identifier: String = "[SYSTEM FONTS]"
        // Here's the functionality that prints all the system fonts.
        for family in UIFont.familyNames as [String] {
            debugPrint("\(identifier) FONT FAMILY :  \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                debugPrint("\(identifier) FONT NAME :  \(name)")
            }
        }
    }
    
    func handleAuthorizationURLWithQuery(_ url: URL) {
        // **Always** validate URLs; they offer a potential attack vector into
        // your app.
        guard url.scheme == self.spotify.loginCallbackURL.scheme else {
            print("not handling URL: unexpected scheme: '\(url)'")
            self.alert = AlertItem(
                title: "Cannot Handle Redirect",
                message: "Unexpected URL"
            )
            return
        }
        
        print("received redirect from Spotify: '\(url)'")
        
        // This property is used to display an activity indicator in `LoginView`
        // indicating that the access and refresh tokens are being retrieved.
        spotify.isRetrievingTokens = true
        
        // Complete the authorization process by requesting the access and
        // refresh tokens.
        spotify.api.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url,
            // This value must be the same as the one used to create the
            // authorization URL. Otherwise, an error will be thrown.
            state: spotify.authorizationState
        )
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { completion in
            // Whether the request succeeded or not, we need to remove the
            // activity indicator.
            self.spotify.isRetrievingTokens = false
            
            /*
             After the access and refresh tokens are retrieved,
             `SpotifyAPI.authorizationManagerDidChange` will emit a signal,
             causing `Spotify.authorizationManagerDidChange()` to be called,
             which will dismiss the loginView if the app was successfully
             authorized by setting the @Published `Spotify.isAuthorized`
             property to `true`.

             The only thing we need to do here is handle the error and show it
             to the user if one was received.
             */
            if case .failure(let error) = completion {
                print("couldn't retrieve access and refresh tokens:\n\(error)")
                let alertTitle: String
                let alertMessage: String
                if let authError = error as? SpotifyAuthorizationError,
                   authError.accessWasDenied {
                    alertTitle = "You Denied The Authorization Request :("
                    alertMessage = ""
                }
                else {
                    alertTitle =
                        "Couldn't Authorization With Your Account"
                    alertMessage = error.localizedDescription
                }
                self.alert = AlertItem(
                    title: alertTitle, message: alertMessage
                )
            }
        })
        .store(in: &cancellables)
        
        // MARK: IMPORTANT: generate a new value for the state parameter after
        // MARK: each authorization request. This ensures an incoming redirect
        // MARK: from Spotify was the result of a request made by this app, and
        // MARK: and not an attacker.
        self.spotify.authorizationState = String.randomURLSafe(length: 128)
        
    }
    
    func handleRefreshAuthorization(_ condition: Bool = true) {
        DispatchQueue.main.async { refreshAuthorization = condition }
    }
    
    func handleStored_sp_dc() {
        guard let stored_sp_dc = defaults.sp_dc else {
            handleRefreshAuthorization()
            return
        }
        
        DispatchQueue.main.async { sp_dc = stored_sp_dc }
    }
    
    func getFriendActivity(_ newValue: String?) {
        guard let newValue else {
            handleRefreshAuthorization()
            return
        }
        
        let openSpotifyAPI = OpenSpotifyAPI()
        openSpotifyAPI.authenticate(spDcCookie: newValue)
        handleRefreshAuthorization(false)
    }
}
