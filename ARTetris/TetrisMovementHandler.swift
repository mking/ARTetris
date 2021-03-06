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
    let lineWidth: Float
    let outLength = Float(3)
    let arrowLength = Float(1)
    
    var centerPosition: SCNVector3 {
        get {
            return SCNVector3(position.x + (((Float(config.length) / 2) - 0.5) * cell), position.y, position.z + (((Float(config.length) / 2) - 0.5) * cell))
        }
    }
    
    init(config: TetrisConfig, position: SCNVector3, cell: Float, lineWidth: Float) {
        self.config = config
        self.position = position
        self.cell = cell
        self.lineWidth = lineWidth
    }
    
    func addArrows(parentNode: SCNNode) {
        let centerX = (Float(config.length - 1) / 2) * cell
        let centerZ = (Float(config.length - 1) / 2) * cell
        let deltaOut = (Float(config.length) / 2) * cell
        let deltaArrow = ((arrowLength / 2) * cell) / sqrt(2)

        for (name, i, signX, signZ) in [("backward", 0, Float(0), Float(-1)), ("left", 1, Float(-1), Float(0)), ("forward", 2, Float(0), Float(1)), ("right", 3, Float(1), Float(0))] {
            let leftMaterial = SCNMaterial()
            leftMaterial.diffuse.contents = UIColor.white
            let leftGeometry = SCNBox(width: CGFloat(lineWidth), height: CGFloat(lineWidth), length: CGFloat(arrowLength * cell), chamferRadius: 0)
            leftGeometry.firstMaterial = leftMaterial
            let leftNode = SCNNode(geometry: leftGeometry)
            leftNode.categoryBitMask = TetrisCategories.segment.rawValue
            leftNode.position = SCNVector3(0, 0, -deltaArrow)
            leftNode.rotation = SCNVector4(0, 1, 0, Float.pi / 4)
            
            let rightMaterial = SCNMaterial()
            rightMaterial.diffuse.contents = UIColor.white
            let rightGeometry = SCNBox(width: CGFloat(lineWidth), height: CGFloat(lineWidth), length: CGFloat(arrowLength * cell), chamferRadius: 0)
            rightGeometry.firstMaterial = rightMaterial
            let rightNode = SCNNode(geometry: rightGeometry)
            rightNode.categoryBitMask = TetrisCategories.segment.rawValue
            rightNode.position = SCNVector3(0, 0, deltaArrow)
            rightNode.rotation = SCNVector4(0, 1, 0, -Float.pi / 4)
            
            let arrowNode = SCNNode()
            arrowNode.name = "arrow-\(name)"
            arrowNode.position = SCNVector3(outLength * cell, 0, 0)
            arrowNode.addChildNode(leftNode)
            arrowNode.addChildNode(rightNode)
            
            let material = SCNMaterial()
            material.diffuse.contents = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
            let rectHeight = CGFloat(10.0 * cell)
            let box = SCNBox(width: rectHeight, height: CGFloat(lineWidth), length: CGFloat(config.length) * CGFloat(cell), chamferRadius: 0.0)
            box.firstMaterial = material
            let rectNode = SCNNode(geometry: box)
            rectNode.name = name
            rectNode.position = SCNVector3(rectHeight / 2, 0, 0)
            rectNode.categoryBitMask = TetrisCategories.arrow.rawValue
            
            let node = SCNNode()
            let deltaX = signX * deltaOut
            let deltaZ = signZ * deltaOut
            node.position = SCNVector3(centerX + deltaX, -0.5 * cell, centerZ + deltaZ)
            node.rotation = SCNVector4(0, 1, 0, (Float.pi / 2) * Float(i + 1))
            node.addChildNode(arrowNode)
            node.addChildNode(rectNode)
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
    
    func flash(node: SCNNode) {
        let segments = node.childNodes(passingTest: { (node, _) in
            return node.categoryBitMask & TetrisCategories.segment.rawValue != 0
        })
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.2
        for segment in segments {
            segment.geometry!.firstMaterial!.diffuse.contents = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        }
        SCNTransaction.completionBlock = {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            for segment in segments {
                segment.geometry!.firstMaterial!.diffuse.contents = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
            SCNTransaction.commit()
        }
        SCNTransaction.commit()
    }
}
