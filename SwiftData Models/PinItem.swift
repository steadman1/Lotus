//
//  PinItems.swift
//  Lotus
//
//  Created by Spencer Steadman on 4/9/24.
//

import Foundation
import SwiftData

@Model 
class PinItem {
    @Attribute(.unique) var uuid: String
    
    init(uuid: String) {
        self.uuid = uuid
    }
}
