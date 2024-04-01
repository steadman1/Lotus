//
//  LoungeGreeting.swift
//  Lotus
//
//  Created by Spencer Steadman on 3/31/24.
//

import SwiftUI
import SteadmanUI

struct LoungeGreeting: View {
    @EnvironmentObject var screen: Screen
    
    private let name = "Spence"
    
    var body: some View {
        let partOfDay = greeting()
        VStack(alignment: .leading, spacing: 0) {
            Text(partOfDay.greeting.uppercased() + ",")
                .font(.serifHeader)
                .foregroundStyle(Color.primaryText)
            HStack(alignment: .center, spacing: Screen.padding / 4) {
                Text(name.uppercased())
                    .font(.serifHeaderItalic)
                    .foregroundStyle(Color.primaryText)
                Image(partOfDay == .evening ? .moon : .sun)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: partOfDay == .evening ? 32 : 40)
                    .foregroundStyle(Color.sunAndMoon)
                    .offset(y: -4)
            }
        }.padding(.horizontal, Screen.padding)
    }
    
    func greeting() -> PartOfDay {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        
        switch hour {
        case 0..<12:
            return .morning
        case 12..<17:
            return .afternoon
        case 17...23:
            return .evening
        default:
            return .evening // Default to evening in case of unexpected hour value
        }
    }
}

enum PartOfDay {
    case morning
    case afternoon
    case evening
    
    var greeting: String {
        switch self {
        case .morning:
            return "Good morning"
        case .afternoon:
            return "Good afternoon"
        case .evening:
            return "Good evening"
        }
    }
}
