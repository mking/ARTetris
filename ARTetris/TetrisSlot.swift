//
//  TetrisSlot.swift
//  ARTetris
//
//  Created by mking on 10/21/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation

class TetrisSlot {
    let name: String?
    
    init(name: String?) {
        self.name = name
    }
    
    var isFilled: Bool {
        get {
            return name != nil
        }
    }
}
