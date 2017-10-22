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
	private var matrix: [[[TetrisSlot]]] = []

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
                matrix[potentialY][potentialX][potentialZ].isFilled
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
    
    public func add(_ current: TetrisState, _ names: [String]) {
		let tetromino = current.tetromino()
		for i in 0...3 {
            // Be careful of index out of range here!
            // Make sure hasCollision is working correctly to prevent this.
            matrix[current.y + tetromino.y(i)][current.x + tetromino.x(i)][current.z + tetromino.z(i)] = TetrisSlot(name: names[i])
		}
	}
	
	public func clearFilledLines() -> TetrisMatrixTransition {
        var removed = Set<String>()
        var score = 0
        loop: for j in 0..<config.width {
            for k in 0..<config.depth {
                if (!matrix[0][j][k].isFilled) {
                    continue loop
                }
            }
            score += 1
            for k in 0..<config.depth {
                removed.insert(matrix[0][j][k].name!)
            }
        }
        loop: for k in 0..<config.depth {
            for j in 0..<config.width {
                if (!matrix[0][j][k].isFilled) {
                    continue loop
                }
            }
            score += 1
            for j in 0..<config.width {
                removed.insert(matrix[0][j][k].name!)
            }
        }
        var newMatrix = [[[TetrisSlot]]]()
        for i in 0..<config.height {
            newMatrix.append([[TetrisSlot]]())
            for j in 0..<config.width {
                newMatrix[i].append([TetrisSlot]())
                for k in 0..<config.depth {
                    newMatrix[i][j].append(matrix[i][j][k])
                }
            }
        }
        for name in removed {
            shiftColumnDown(matrix: &newMatrix, name: name)
        }
        
        let oldMatrix = matrix
        matrix = newMatrix
        return TetrisMatrixTransition(oldMatrix: oldMatrix, newMatrix: newMatrix, removed: removed, score: score)
	}
    
    func shiftColumnDown(matrix: inout [[[TetrisSlot]]], name: String) {
        for i in 0..<config.height {
            for j in 0..<config.width {
                for k in 0..<config.depth {
                    if matrix[i][j][k].name != nil && matrix[i][j][k].name! == name {
                        for ii in i..<config.height - 1 {
                            matrix[ii][j][k] = matrix[ii + 1][j][k]
                        }
                    }
                }
            }
        }
    }
    
    private func addLine() {
        // Add a collision plane
        // The center is collision free (false values)
        let row = [[TetrisSlot]](repeating: [TetrisSlot](repeating: TetrisSlot(name: nil), count: config.depth), count: config.width)
        matrix.append(row)
    }
	
}
