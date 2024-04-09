//
//  FolderItem.swift
//  Lotus
//
//  Created by Spencer Steadman on 4/9/24.
//

import Foundation
import SwiftData

@Model
class FolderItem {
    var name: String
    var image: Data?
    var items: [String]
    
    init() {
        self.name = "Untitled"
        self.image = nil
        self.items = []
    }
    
    init(name: String, image: Data, items: [String]) {
        self.name = name
        self.image = image
        self.items = items
    }
}
