//
//  TetrisMovementHandler.swift
//  ARTetris
//
//  Created by mking on 10/28/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import ARKit
import SceneKit

class TetrisMovementHandler {
    let config: TetrisConfig
    let position: SCNVector3
    let cell: Float
    let outLength = Float(3)
    let arrowLength = Float(1)
    
    var centerPosition: SCNVector3 {
        get {
            return SCNVector3(position.x + (((Float(config.length) / 2) - 0.5) * cell), position.y, position.z + (((Float(config.length) / 2) - 0.5) * cell))
        }
    }
    
    init(config: TetrisConfig, position: SCNVector3, cell: Float) {
        self.config = config
        self.position = position
        self.cell = cell
    }
    
    func addArrows(parentNode: SCNNode) {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        
        let geometry = SCNBox(width: CGFloat(0.001), height: CGFloat(0.001), length: CGFloat(arrowLength * cell), chamferRadius: 0)
        geometry.firstMaterial = material
        
        let centerX = (Float(config.length - 1) / 2) * cell
        let centerZ = (Float(config.length - 1) / 2) * cell
        let deltaOut = ((Float(config.length) + outLength) / 2) * cell
        let deltaArrow = ((arrowLength / 2) * cell) / sqrt(2)

        for (i, signX, signZ) in [(0, Float(0), Float(-1)), (1, Float(-1), Float(0)), (2, Float(0), Float(1)), (3, Float(1), Float(0))] {
            let leftNode = SCNNode(geometry: geometry)
            leftNode.position = SCNVector3(0, 0, -deltaArrow)
            leftNode.rotation = SCNVector4(0, 1, 0, Float.pi / 4)
            
            let rightNode = SCNNode(geometry: geometry)
            rightNode.position = SCNVector3(0, 0, deltaArrow)
            rightNode.rotation = SCNVector4(0, 1, 0, -Float.pi / 4)
            
            let node = SCNNode()
            let deltaX = signX * deltaOut
            let deltaZ = signZ * deltaOut
            node.position = SCNVector3(centerX + deltaX, -0.5 * cell, centerZ + deltaZ)
            node.rotation = SCNVector4(0, 1, 0, (Float.pi / 2) * Float(i + 1))
            node.addChildNode(leftNode)
            node.addChildNode(rightNode)
            parentNode.addChildNode(node)
        }
    }
    
    func tap(tapPosition: SCNVector3, sceneView: ARSCNView) -> TetrisMovementDirection {
        let relativeX = tapPosition.x - centerPosition.x
        let relativeZ = tapPosition.z - centerPosition.z
        if abs(relativeX) > abs(relativeZ) {
            return relativeX < 0 ? .left : .right
        } else {
            return relativeZ < 0 ? .backward : .forward
        }
    }
    
    func addMarker(position: SCNVector3, sceneView: ARSCNView) {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        
        let box = SCNBox(width: CGFloat(cell), height: CGFloat(cell), length: CGFloat(cell), chamferRadius: 0)
        box.firstMaterial = material
        
        let node = SCNNode(geometry: box)
        node.position = position
        sceneView.scene.rootNode.addChildNode(node)
    }
}
