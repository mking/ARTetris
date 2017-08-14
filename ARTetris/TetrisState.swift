//
//  State.swift
//  ARTetris
//
//  Created by Yuri Strot on 6/30/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation

/** Tetris game state: current tetromino and its position in the well */
class TetrisState {
	
	static func random(_ config: TetrisConfig) -> TetrisState {
		return TetrisState(random(OneSidedTetromino.all.count), random(4), config.width / 2, config.height, config.depth / 2, 0)
	}
	
	let index: Int
	let rotation: Int
	let x: Int
	let y: Int
    let z: Int
    let ghostY: Int
	
    private init(_ index: Int, _ rotation: Int, _ x: Int, _ y: Int, _ z: Int, _ ghostY: Int) {
		self.index = index
		self.rotation = rotation
		self.x = x
		self.y = y
        self.z = z
        self.ghostY = ghostY
	}
	
	func tetromino() -> FixedTetromino { return OneSidedTetromino.all[index].fixed[rotation] }
	
	func rotate() -> TetrisState { return TetrisState(index, (rotation + 1) % 4, x, y, z, ghostY) }
    
    func forward() -> TetrisState { return TetrisState(index, rotation, x, y, z + 1, ghostY) }
    
    func backward() -> TetrisState { return TetrisState(index, rotation, x, y, z - 1, ghostY) }
    
	func left() -> TetrisState { return TetrisState(index, rotation, x - 1, y, z, ghostY) }
	
	func right() -> TetrisState { return TetrisState(index, rotation, x + 1, y, z, ghostY) }
	
	func down() -> TetrisState { return TetrisState(index, rotation, x, y - 1, z, ghostY) }
    
    func withGhost(ghostY: Int) -> TetrisState {
        return TetrisState(index, rotation, x, y, z, ghostY)
    }
	
	private static func random(_ max: Int) -> Int {
		return Int(arc4random_uniform(UInt32(max)))
	}
	
}
