//
//  Item.swift
//  InSessionRadioShow
//
//  Created by MARITZA  DAVID GALINDO on 15/03/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
