//
//  Extensions.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/28/24.
//

import SwiftUI
import SteadmanUI

extension Font {
    static var sfProDisplayCaption: Font {
        Font.custom("SF Compact Display", size: 10)
            .weight(.medium)
    }
    static var uiSFProDisplayCaption: UIFont {
        UIFont(name: "SFCompactDisplay-Medium", size: 10)!
    }
    
    static var sfProDisplayBody: Font {
        Font.custom("SF Pro Display", size: 16)
            .weight(.regular)
    }
    static var uiSFProDisplayBody: UIFont {
        UIFont(name: "SFProDisplay-Medium", size: 16)!
    }
    
    static var sfProDisplayTitle: Font {
        Font.custom("SF Pro Display", size: 20)
            .weight(.bold)
    }
    static var uiSFProDisplayTitle: UIFont {
        UIFont(name: "SFProDisplay-Medium", size: 20)!
    }
    
    // Serif Header Fonts
    static var serifHeader: Font {
        Font.custom("TimesNewRomanMTStd-Cond", size: 44)
            .weight(.regular)
    }
    static var uiSerifHeader: UIFont {
        UIFont(name: "TimesNewRomanMTStd-Cond", size: 44)!
    }
    
    // Italic Serif Header Fonts
    static var serifHeaderItalic: Font {
        Font.custom("TimesNewRomanMTStd-CondIt", size: 44)
            .weight(.regular)
    }
    static var uiSerifHeaderItalic: UIFont {
        UIFont(name: "TimesNewRomanMTStd-CondIt", size: 44)!
    }
    
    // Serif Body Fonts
    static var serifBody: Font {
        Font.custom("TimesNewRomanMTStd-Cond", size: 18)
            .weight(.regular)
    }
    static var uiSerifBody: UIFont {
        UIFont(name: "TimesNewRomanMTStd-Cond", size: 18)!
    }
    
    // Serif Body Fonts
    static var serifCaption: Font {
        Font.custom("TimesNewRomanMTStd-Cond", size: 14)
            .weight(.regular)
    }
    static var uiSerifCaption: UIFont {
        UIFont(name: "TimesNewRomanMTStd-Cond", size: 14)!
    }
    
    // Sans Body Fonts
    static var sansSubtitle: Font {
        Font.custom("Newake", size: 24)
    }
    static var uiSansSubtitle: UIFont {
        UIFont(name: "Newake", size: 24)!
    }
    
    // Sans Body Fonts
    static var sansBody: Font {
        Font.custom("Newake", size: 16)
    }
    static var uiSansBody: UIFont {
        UIFont(name: "Newake", size: 16)!
    }
    
    // Sans Navigaiton Header Fonts
    static var sansNavigationHeader: Font {
        Font.custom("Newake", size: 98)
    }
    static var uiSansNavigationHeader: UIFont {
        UIFont(name: "Newake", size: 98)!
    }
    
    // Serif Navigaiton Fonts
    static var serifNavigation: Font {
        Font.custom("TimesNewRomanMTStd-Cond", size: 16)
            .weight(.medium)
    }
    static var uiSansNavigation: UIFont {
        UIFont(name: "TimesNewRomanMTStd-Cond", size: 16)!
    }
}

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
}

extension Date {
    func timeAgo() -> String {
        let now = Date()
        let difference = Calendar.current.dateComponents([.minute, .hour, .day, .weekOfYear, .month, .year], from: self, to: now)
        
        if let year = difference.year, year > 0 {
            return "\(year)y ago"
        } else if let month = difference.month, month > 0 {
            return "\(month)mo ago"
        } else if let week = difference.weekOfYear, week > 0 {
            return "\(week)w ago"
        } else if let day = difference.day, day > 0 {
            return "\(day)d ago"
        } else if let hour = difference.hour, hour > 0 {
            return "\(hour)hr ago"
        } else if let minute = difference.minute, minute > 8 {
            return "\(minute)m ago"
        } else {
            return "Now"
        }
    }
}

extension URL {
    func convertToHTTPS() -> URL {
        // check if scheme is already https
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true), components.scheme != "https" else {
            return self
        }
        
        // Change the scheme to https
        components.scheme = "https"
        
        // Return the new URL, or nil if there was an issue constructing it
        return components.url!
    }
}

public struct WithNavBarPadding: ViewModifier {
    
    let withTheEnd: Bool
    
    private let theEndHeight: CGFloat = 100
    
    public func body(content: Content) -> some View {
        let scale: CGFloat = Screen.shared.width * 2 / theEndHeight
        let navBarPadding: CGFloat = 2 + Screen.padding
        VStack {
            content
            
            if withTheEnd {
                ZStack(alignment: .top) {
                    Circle()
                        .stroke(Color.foreground, lineWidth: 1 / scale)
                        .scaleEffect(x: scale * 1.2, y: scale)
                        .offset(y: Screen.shared.width - theEndHeight / 2)
                    
                    Text("The End")
                        .font(.serifBody)
                        .foregroundStyle(Color.primaryText)
                        .offset(y: theEndHeight / 3)
                }.frame(maxWidth: .infinity)
                    .frame(height: theEndHeight)
            }
            
            Spacer().frame(height: calculateNavBarPadding())
        }
    }
    
    private func calculateNavBarPadding() -> CGFloat {
        let text = "Library"
        let padding = text.heightOfString(usingFont: Font.uiSerifBody) +
        text.heightOfString(usingFont: Font.uiSansNavigation) + Screen.shared.safeAreaInsets.bottom + Screen.padding * 4 + 2
        
        return padding
    }
}

extension View {
    func withNavBarPadding() -> some View {
        self.modifier(WithNavBarPadding(withTheEnd: false))
    }
    
    func withNavBarTheEnd() -> some View {
        self.modifier(WithNavBarPadding(withTheEnd: true))
    }
}
