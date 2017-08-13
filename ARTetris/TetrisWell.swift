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
        matrix.append([[Bool]](repeating: [Bool](repeating: true, count: config.depth + 2), count: config.width + 2))
		for _ in 0...config.height + 3 {
			addLine()
		}
	}
	
	public func hasCollision(_ state: TetrisState) -> Bool {
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
		loop: for i in 1...config.height + 1 {
			for j in 1...config.width {
                for k in 1...config.depth {
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
        var row = [[Bool]](repeating: [Bool](repeating: false, count: config.depth + 2), count: config.width + 2)
        
        for i in 0...config.width + 1 {
            for j in 0...config.depth + 1 {
                row[i][j] = i == 0 || i == config.width + 1 || j == 0 || j == config.depth + 1
            }
        }
        
		matrix.append(row)
	}
	
}
