//
//  AppointmentsWidgetLiveActivity.swift
//  AppointmentsWidget
//
//  Created by admin on 10.03.2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct AppointmentsWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct AppointmentsWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AppointmentsWidgetAttributes.self) { context in
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

extension AppointmentsWidgetAttributes {
    fileprivate static var preview: AppointmentsWidgetAttributes {
        AppointmentsWidgetAttributes(name: "World")
    }
}

extension AppointmentsWidgetAttributes.ContentState {
    fileprivate static var smiley: AppointmentsWidgetAttributes.ContentState {
        AppointmentsWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: AppointmentsWidgetAttributes.ContentState {
         AppointmentsWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: AppointmentsWidgetAttributes.preview) {
   AppointmentsWidgetLiveActivity()
} contentStates: {
    AppointmentsWidgetAttributes.ContentState.smiley
    AppointmentsWidgetAttributes.ContentState.starEyes
}
