//
//  ARTetrisTests.swift
//  ARTetrisTests
//
//  Created by mking on 9/9/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import XCTest
import SceneKit

class ARTetrisTests: XCTestCase {
    
    class Tetronimo {
        let points: [SCNVector3]
        
        init(points: [SCNVector3]) {
            self.points = points
        }
        
        func rotateX(angle: Float) -> Tetronimo {
            let rotateMatrix = simd_float4x4(SCNMatrix4MakeRotation(angle, 1, 0, 0))
            return rotate(rotateMatrix: rotateMatrix)
        }
        
        func rotateY(angle: Float) -> Tetronimo {
            let rotateMatrix = simd_float4x4(SCNMatrix4MakeRotation(angle, 0, 1, 0))
            return rotate(rotateMatrix: rotateMatrix)
        }
        
        func rotate(rotateMatrix: simd_float4x4) -> Tetronimo {
            let rotatedPoints = self.points.map { point -> SCNVector3 in
                let translateMatrix = simd_float4x4(SCNMatrix4MakeTranslation(point.x, point.y, point.z))
                let rotatedMatrix = simd_mul(rotateMatrix, translateMatrix)
                return SCNVector3(
                    Tetronimo.normalize(value: rotatedMatrix[3][0]),
                    Tetronimo.normalize(value: rotatedMatrix[3][1]),
                    Tetronimo.normalize(value: rotatedMatrix[3][2])
                )
            }
            return Tetronimo(points: rotatedPoints)
        }
        
        static func normalize(value: Float) -> Float {
            return positiveZero(value: round(value))
        }
        
        static func positiveZero(value: Float) -> Float {
            return value == 0 ? 0 : value
        }
    }
    
    func testRotateTetronimo() {
        let tetronimo = Tetronimo(points: [
            SCNVector3(0, 1, 0),
            SCNVector3(-1, 0, 0),
            SCNVector3(0, 0, 0),
            SCNVector3(1, 0, 0)
        ])
        
        let rotatedTetronimo = tetronimo.rotateY(angle: Float.pi)
        print(rotatedTetronimo)
    }
    
//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//
//    func testExample() {
////        XCTAssert(false, "this test must be true")
////
////        XCTAssertEqual(1, 2, "these values must be equal")
//
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//
}
