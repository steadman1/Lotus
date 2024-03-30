//
//  Extensions.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/28/24.
//

import SwiftUI

extension Font {
    static var serifTitle: Font {
        Font.custom("TimesNewRomanMTStd-Cond", size: 40)
            .weight(.regular)
    }
    static var serifTitleItalic: Font {
        Font.custom("TimesNewRomanMTStd-CondIt", size: 40)
            .weight(.regular)
    }
    static var sansOperator: Font {
        Font.custom("Noto Sans", size: 24)
            .weight(.regular)
    }
    static var serifBody: Font {
        Font.custom("TimesNewRomanMTStd-Cond", size: 16)
            .weight(.regular)
    }
    static var sansNavigation: Font {
        Font.custom("TimesNewRomanMTStd-Cond", size: 12)
            .weight(.medium)
    }
}
