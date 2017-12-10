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
    // Start at lower than the top in case the tetromino exceeds the ceiling...
    // TODO We do not need ceiling collision detection...
	static func random(_ config: TetrisConfig) -> TetrisState {
		return TetrisState(random(Tetromino.all.count), 1, random(4), config.width / 2, config.height - 2, config.depth / 2)
	}
	
	let index: Int
	let rotationX: Int
    let rotationY: Int
	let x: Int
	let y: Int
    let z: Int
	
    private init(_ index: Int, _ rotationX: Int, _ rotationY: Int, _ x: Int, _ y: Int, _ z: Int) {
		self.index = index
		self.rotationX = rotationX
        self.rotationY = rotationY
		self.x = x
		self.y = y
        self.z = z
        
//        print("+++ rotation state is now \(rotationX) \(rotationY)")
	}
	
	func tetromino() -> Tetromino { return Tetromino.all[index].rotate(x: rotationX, y: rotationY) }
    
    func rotateY(_ angle: Int) -> TetrisState { return TetrisState(index, rotationX, (rotationY + angle + 4) % 4, x, y, z) }
    
    func forward() -> TetrisState { return TetrisState(index, rotationX, rotationY, x, y, z + 1) }
    
    func backward() -> TetrisState { return TetrisState(index, rotationX, rotationY, x, y, z - 1) }
    
	func left() -> TetrisState { return TetrisState(index, rotationX, rotationY, x - 1, y, z) }
    
    func right() -> TetrisState { return TetrisState(index, rotationX, rotationY, x + 1, y, z) }
	
	func down() -> TetrisState { return TetrisState(index, rotationX, rotationY, x, y - 1, z) }
	
	private static func random(_ max: Int) -> Int {
		return Int(arc4random_uniform(UInt32(max)))
	}
	
}
