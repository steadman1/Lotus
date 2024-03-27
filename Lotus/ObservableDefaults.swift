//
//  ObservableDefaults.swift
//  ponder
//
//  Created by Spencer Steadman on 10/31/23.
//

import Foundation
import Combine
import UIKit

class ObservableDefaults: ObservableObject {
    static var shared = ObservableDefaults()
    
    @Published var sp_dc: String? {
        didSet {
            UserDefaults.standard.set(self.sp_dc, forKey: ObservableDefaults.sp_dcRoute)
        }
    }

    init() {
        self.sp_dc = UserDefaults.standard.string(forKey: ObservableDefaults.sp_dcRoute)
    }
    
    static let sp_dcRoute = "sp_dc"
}
