//
//  Tetromino.swift
//  ARTetris
//
//  Created by Yuri Strot on 6/27/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import SceneKit

class Tetromino {
    
    static let all = [t, j, l, s, z, o, i]
//    static let all = [o]
    
    static let t = Tetromino([
        0, 1, 0,
        -1, 0, 0,
        0, 0, 0,
        1, 0, 0
    ])
    
    static let j = Tetromino([
        0, 1, 0,
        0, 0, 0,
        0, -1, 0,
        -1, -1, 0,
    ])
    
    static let l = Tetromino([
        0, 1, 0,
        0, 0, 0,
        0, -1, 0,
        1, -1, 0,
    ])
    
    static let s = Tetromino([
        0, 1, 0,
        1, 1, 0,
        0, 0, 0,
        -1, 0, 0,
    ])
    
    static let z = Tetromino([
        0, 1, 0,
        -1, 1, 0,
        0, 0, 0,
        1, 0, 0,
    ])
    
    static let o = Tetromino([
        -1, 1, 0,
        0, 1, 0,
        -1, 0, 0,
        0, 0, 0,
    ])
    
    static let i = Tetromino([
        0, 2, 0,
        0, 1, 0,
        0, 0, 0,
        0, -1, 0,
    ])
    
    let values: [Int]
	
	init(_ values: [Int]) { self.values = values }
    
	func x(_ index: Int) -> Int { return values[index * 3] }
    
	func y(_ index: Int) -> Int { return values[index * 3 + 1] }
    
    func z(_ index: Int) -> Int { return values[index * 3 + 2] }
    
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
            let point = SCNVector3(x(i), y(i), z(i))
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
