//
//  TetrisWell.swift
//  ARTetris
//
//  Created by Yuri Strot on 6/29/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

/** Tetris well model */
class TetrisWell {
	
	private let config: TetrisConfig
	private var matrix: [[[Bool]]] = []

	init(_ config: TetrisConfig) {
		self.config = config
        
        // Init the matrix
        for _ in 0..<config.height {
            addLine()
        }
	}
    
    public func hasCollision(_ state: TetrisState) -> Bool {
        return hasWallCollision(state) || hasBlockCollision(state)
    }
    
    // Side or floor collision
    public func hasWallCollision(_ state: TetrisState) -> Bool {
        // Check all the blocks of the teromino
        let tetromino = state.tetromino()
        for i in 0...3 {
            let potentialX = state.x + tetromino.x(i)
            let potentialY = state.y + tetromino.y(i)
            let potentialZ = state.z + tetromino.z(i)
            if (
                potentialX < 0 || potentialX >= config.width || potentialY < 0 || potentialZ < 0 || potentialZ >= config.depth
            ) {
                return true
            }
        }
        return false
    }
    
    // Block collision
    public func hasBlockCollision(_ state: TetrisState) -> Bool {
        let tetromino = state.tetromino()
        for i in 0...3 {
            let potentialX = state.x + tetromino.x(i)
            let potentialY = state.y + tetromino.y(i)
            let potentialZ = state.z + tetromino.z(i)
            if (
                potentialX >= 0 && potentialX < config.width &&
                potentialY >= 0 && potentialY < config.height &&
                potentialZ >= 0 && potentialZ < config.depth &&
                matrix[potentialY][potentialX][potentialZ]
            ) {
                return true
            }
        }
        return false
    }
    
	public func add(_ current: TetrisState) {   
		let tetromino = current.tetromino()
		for i in 0...3 {
			matrix[current.y + tetromino.y(i)][current.x + tetromino.x(i)][current.z + tetromino.z(i)] = true
		}
	}
	
	public func clearFilledLines() -> [Int] {
		var toRemove: [Int] = []
		loop: for i in 1..<config.height {
			for j in 1..<config.width {
                for k in 1..<config.depth {
                    if (!matrix[i][j][k]) {
                        continue loop
                    }
                }
			}
			toRemove.append(i)
		}
		toRemove.reverse()
		for i in toRemove {
			matrix.remove(at: i)
			addLine()
		}
		return toRemove
	}
    
    private func addLine() {
        // Add a collision plane
        // The center is collision free (false values)
        let row = [[Bool]](repeating: [Bool](repeating: false, count: config.depth), count: config.width)
        matrix.append(row)
    }
	
}
