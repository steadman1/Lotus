//
//  Extensions.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/28/24.
//

import SwiftUI

extension Font {
    static var serifHeader: Font {
        Font.custom("TimesNewRomanMTStd-Cond", size: 44)
            .weight(.regular)
    }
    static var serifHeaderItalic: Font {
        Font.custom("TimesNewRomanMTStd-CondIt", size: 44)
            .weight(.regular)
    }
    static var serifBody: Font {
        Font.custom("TimesNewRomanMTStd-Cond", size: 16)
            .weight(.regular)
    }
    static var sansNavigationHeader: Font {
        Font.custom("Newake", size: 98)
    }
    static var serifNavigation: Font {
        Font.custom("TimesNewRomanMTStd-Cond", size: 16)
            .weight(.medium)
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
