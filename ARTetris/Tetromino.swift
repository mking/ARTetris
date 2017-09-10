//
//  Tetromino.swift
//  ARTetris
//
//  Created by Yuri Strot on 6/27/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import SceneKit

class Tetromino {
    
    static let all = [t]
    
    static let t = Tetromino([
        0, 1, 0,
        -1, 0, 0,
        0, 0, 0,
        1, 0, 0
    ])
    
    // Translate x, y, z coords by an initial offset to avoid negative coords
    // Adjust the scene size in TetrisWell if you change this offset!
    static let offset = 1
	
    let values: [Int]
	
	init(_ values: [Int]) { self.values = values }
    
	func x(_ index: Int) -> Int { return values[index * 3] + Tetromino.offset }
    
	func y(_ index: Int) -> Int { return values[index * 3 + 1] + Tetromino.offset }
    
    func z(_ index: Int) -> Int { return values[index * 3 + 2] + Tetromino.offset }
    
    func rotate(x: Int, y: Int) -> Tetromino {
        return rotateX(angle: x).rotateY(angle: y)
    }
    
    func rotateX(angle: Int) -> Tetromino {
        let rotateMatrix = simd_float4x4(SCNMatrix4MakeRotation(Float(angle) * (Float.pi / 2), 1, 0, 0))
        return rotate(rotateMatrix: rotateMatrix)
    }
    
    func rotateY(angle: Int) -> Tetromino {
        let rotateMatrix = simd_float4x4(SCNMatrix4MakeRotation(Float(angle) * (Float.pi / 2), 0, 1, 0))
        return rotate(rotateMatrix: rotateMatrix)
    }
    
    func rotate(rotateMatrix: simd_float4x4) -> Tetromino {
        let rotatedValues = (0...3).flatMap { i -> [Int] in
            let point = SCNVector3(x(i) - Tetromino.offset, y(i) - Tetromino.offset, z(i) - Tetromino.offset)
            let translateMatrix = simd_float4x4(SCNMatrix4MakeTranslation(point.x, point.y, point.z))
            let rotatedMatrix = simd_mul(rotateMatrix, translateMatrix)
            return [
                normalize(value: rotatedMatrix[3][0]),
                normalize(value: rotatedMatrix[3][1]),
                normalize(value: rotatedMatrix[3][2])
            ]
        }
        return Tetromino(rotatedValues)
    }
    
    func normalize(value: Float) -> Int {
        return Int(round(value))
    }
}
