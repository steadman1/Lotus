//
//  LiveFriendActivityLiveActivity.swift
//  LiveFriendActivity
//
//  Created by Spencer Steadman on 4/2/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LiveFriendActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var trackName: String
        var trackArtist: String
        var trackImageData: Data
        var timestamp: TimeInterval
        var isSaved: Bool
    }

    // Fixed non-changing properties about your activity go here!
    var profileData: Data
    var name: String
}

struct LiveFriendActivityLiveActivity: Widget {
    private let ColorSpotify = Color(red: 0.11, green: 0.73, blue: 0.33)
    private let trackSize: CGFloat = 64
    private let profileSize: CGFloat = 24
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveFriendActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        HStack {
                            Image(uiImage: UIImage(data: context.attributes.profileData) ?? UIImage())
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: profileSize, height: profileSize)
                                .clipShape(Circle())
                            VStack(alignment: .leading) {
                                Text("Tuned into".uppercased())
                                    .font(.sfProDisplayCaption.uppercaseSmallCaps())
                                    .foregroundStyle(.white.opacity(0.6))
                                Text("@" + context.attributes.name)
                                    .font(.sfProDisplayBody)
                                    .foregroundStyle(.white)
                            }
                        }
                        
                        Spacer()
                        
                        Text(Date(timeIntervalSince1970:
                                    TimeInterval(context.state.timestamp)).timeAgo())
                            .font(.sfProDisplayBody)
                            .foregroundStyle(.white)
                    }
                    
                    HStack(spacing: 8) {
                        Image(uiImage: UIImage(data: context.state.trackImageData) ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: trackSize, height: trackSize)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        VStack(alignment: .leading) {
                            Spacer()
                            Text(context.state.trackName)
                                .font(.sfProDisplayTitle)
                                .foregroundStyle(.white)
                            Text(context.state.trackArtist)
                                .font(.sfProDisplayBody)
                                .foregroundStyle(.white.opacity(0.6))
                            Spacer()
                            let maxWidth: CGFloat = (geometry.size.width - trackSize - CGFloat(40))
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 100)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 5)
                                    .foregroundStyle(Color.spotify.opacity(0.6))
                                RoundedRectangle(cornerRadius: 100)
                                    .frame(width: max(min(maxWidth * (Date().timeIntervalSince1970 - context.state.timestamp) / (3 * 60), maxWidth), 10))
                                    .frame(height: 5)
                                    .foregroundStyle(Color.spotify)
                            }
                        }
                    }
                }.padding(16)
                    .background(Color.black)
            }.frame(height: 32 + trackSize + 8
                    + max("|".heightOfString(usingFont: Font.uiSFProDisplayBody)
                          + "|".heightOfString(usingFont: Font.uiSFProDisplayCaption),
                          profileSize))

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.trackName)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.trackName)")
            } minimal: {
                Text(context.state.trackName)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension LiveFriendActivityAttributes {
    fileprivate static var preview: LiveFriendActivityAttributes {
        LiveFriendActivityAttributes(profileData: try! Foundation.Data(contentsOf: URL(string: "https://upload.wikimedia.org/wikipedia/en/9/9b/Tame_Impala_-_Currents.png")!) ?? Data(),
                                     name: "spence")
    }
}

extension LiveFriendActivityAttributes.ContentState {
    fileprivate static var tameImpala: LiveFriendActivityAttributes.ContentState {
        LiveFriendActivityAttributes.ContentState(trackName: "Eventually",
                                                  trackArtist: "Tame Impala",
                                                  trackImageData: try! Data(contentsOf: URL(string: "https://upload.wikimedia.org/wikipedia/en/9/9b/Tame_Impala_-_Currents.png")!) ?? Data(),
                                                  timestamp: Date().timeIntervalSince1970,
                                                  isSaved: true)
     }
}

#Preview("Notification", as: .content, using: LiveFriendActivityAttributes.preview) {
   LiveFriendActivityLiveActivity()
} contentStates: {
    LiveFriendActivityAttributes.ContentState.tameImpala
}
