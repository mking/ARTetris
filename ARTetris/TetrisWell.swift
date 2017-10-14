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
        let tetromino = state.tetromino()
        for i in 0...3 {
            let potentialX = state.x + tetromino.x(i)
            let potentialY = state.y + tetromino.y(i)
            let potentialZ = state.z + tetromino.z(i)
            if (
                // side, ceiling, or floor collision
                potentialX < 0 ||
                potentialX >= config.width ||
                potentialY < 0 ||
                potentialY >= config.height ||
                potentialZ < 0 ||
                potentialZ >= config.depth ||
                // block collision
                matrix[potentialY][potentialX][potentialZ]
            ) {
                return true
            }
        }
        return false
    }
    
    // 1 for left; 2 for right; 3 for back; 4 for front
    public func hasSideCollision(_ state: TetrisState) -> Int {
        let tetromino = state.tetromino()
        for i in 0...3 {
            let potentialX = state.x + tetromino.x(i)
            let potentialZ = state.z + tetromino.z(i)

            if (potentialX < 0) {
                return 1
            }

            if (potentialX >= config.width) {
                return 2
            }

            if (potentialZ < 0) {
                return 3
            }

            if (potentialZ >= config.depth) {
                return 4
            }
        }
        return 0
    }
    
	public func add(_ current: TetrisState) {   
		let tetromino = current.tetromino()
		for i in 0...3 {
            // Be careful of index out of range here!
            // Make sure hasCollision is working correctly to prevent this.
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
