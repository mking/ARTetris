//
//  TetrisMatrixTransition.swift
//  ARTetris
//
//  Created by mking on 10/21/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation

class TetrisMatrixTransition {
    let oldMatrix: [[[TetrisSlot]]]
    let newMatrix: [[[TetrisSlot]]]
    let removed: Set<String>
    let score: Int
    
    init(oldMatrix: [[[TetrisSlot]]], newMatrix: [[[TetrisSlot]]], removed: Set<String>, score: Int) {
        self.oldMatrix = oldMatrix
        self.newMatrix = newMatrix
        self.removed = removed
        self.score = score
    }
    
    func isEmpty() -> Bool {
        return removed.isEmpty
    }
    
    func positionByName(matrix: [[[TetrisSlot]]]) -> [String: Int] {
        var result = [String: Int]()
        for i in 0..<matrix.count {
            for j in 0..<matrix[i].count {
                for k in 0..<matrix[i][j].count {
                    if matrix[i][j][k].isFilled {
                        result[matrix[i][j][k].name!] = j
                    }
                }
            }
        }
        return result
    }
    
    func heightTransitions() -> [TetrisHeightTransition] {
        // the new keys are a subset of the old keys (some keys were removed because lines were collapsed)
        let oldPositionByName = positionByName(matrix: oldMatrix)
        let newPositionByName = positionByName(matrix: newMatrix)
        return newPositionByName.keys
            .filter { (name) in
                return oldPositionByName[name]! != newPositionByName[name]!
            }
            .map { (name) in
                return TetrisHeightTransition(name: name, oldY: oldPositionByName[name]!, newY: newPositionByName[name]!)
            }
    }
}
