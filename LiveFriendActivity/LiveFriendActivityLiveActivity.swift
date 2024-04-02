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
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct LiveFriendActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveFriendActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

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
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension LiveFriendActivityAttributes {
    fileprivate static var preview: LiveFriendActivityAttributes {
        LiveFriendActivityAttributes(name: "World")
    }
}

extension LiveFriendActivityAttributes.ContentState {
    fileprivate static var smiley: LiveFriendActivityAttributes.ContentState {
        LiveFriendActivityAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: LiveFriendActivityAttributes.ContentState {
         LiveFriendActivityAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: LiveFriendActivityAttributes.preview) {
   LiveFriendActivityLiveActivity()
} contentStates: {
    LiveFriendActivityAttributes.ContentState.smiley
    LiveFriendActivityAttributes.ContentState.starEyes
}
