//
//  TetrisConfig.swift
//  ARTetris
//
//  Created by Yuri Strot on 7/3/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

/** Tetris configuration: width and height of the well */
struct TetrisConfig {
	
    static let standard: TetrisConfig = TetrisConfig(width: 8, height: 20, depth: 8)
    
	let width: Int
	let height: Int
    let depth: Int

    var matrixHeight: Int {
        get {
            return height + 2
        }
    }
}

