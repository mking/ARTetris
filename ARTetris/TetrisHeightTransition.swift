//
//  TetrisHeightTransition.swift
//  ARTetris
//
//  Created by mking on 10/21/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation

class TetrisHeightTransition {
    let name: String
    let oldY: Int
    let newY: Int
    
    init(name: String, oldY: Int, newY: Int) {
        self.name = name
        self.oldY = oldY
        self.newY = newY
    }
}
