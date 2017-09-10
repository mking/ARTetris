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
        
        // Add a collision boundary at the top of the well.
        matrix.append([[Bool]](repeating: [Bool](repeating: true, count: config.fullDepth), count: config.fullWidth))
        
		for _ in 0..<config.fullHeight {
			addLine()
		}
	}
	
	public func hasCollision(_ state: TetrisState) -> Bool {
        // There is only one active tetronimo at a time.
        // It has exactly 4 blocks.
        // If any part of the translated and rotated tetronimo (given by state.blah + tetronimo.blah) overlaps with a true value in the matrix,
        // there is a collision with the well.
        
        // This function is used to test potential states (hasCollision(state.down())).
        // If the potential state is invalid, disallow it.
        
		let tetromino = state.tetromino()
		for i in 0...3 {
			if (matrix[state.y + tetromino.y(i)][state.x + tetromino.x(i)][state.z + tetromino.z(i)]) {
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
		loop: for i in 1..<config.fullHeight {
			for j in 1..<config.fullWidth {
                for k in 1..<config.fullDepth {
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
        var row = [[Bool]](repeating: [Bool](repeating: false, count: config.fullDepth), count: config.fullWidth)
        
        // The edges are collision boundary (true values)
        // Both width and depth have 2 extra indexes to hold the collision boundary
        for i in 0..<config.fullWidth {
            for j in 0..<config.fullDepth {
                row[i][j] = i == 0 || i == config.fullWidth - 1 || j == 0 || j == config.fullDepth - 1
            }
        }
        
		matrix.append(row)
	}
	
}
