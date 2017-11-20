//
//  TetrisConfig.swift
//  ARTetris
//
//  Created by Yuri Strot on 7/3/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

/** Tetris configuration: width and height of the well */
struct TetrisConfig {
	
    static let standard: TetrisConfig = TetrisConfig(length: 6, height: 4)
    
    let length: Int
	let height: Int
    
    var width: Int {
        get {
            return length
        }
    }
    
    var depth: Int {
        get {
            return length
        }
    }

    var matrixHeight: Int {
        get {
            return height + 2
        }
    }
}

