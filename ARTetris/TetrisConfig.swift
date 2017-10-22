//
//  TetrisConfig.swift
//  ARTetris
//
//  Created by Yuri Strot on 7/3/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

/** Tetris configuration: width and height of the well */
struct TetrisConfig {
	
    static let standard: TetrisConfig = TetrisConfig(width: 6, height: 20, depth: 6)
    //    static let standard: TetrisConfig = TetrisConfig(width: 4, height: 10, depth: 4)
    
	let width: Int
	let height: Int
    let depth: Int
}

