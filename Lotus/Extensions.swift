//
//  Extensions.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/28/24.
//

import SwiftUI

extension Font {
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
