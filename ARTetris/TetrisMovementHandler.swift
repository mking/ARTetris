//
//  TetrisMovementHandler.swift
//  ARTetris
//
//  Created by mking on 10/28/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import ARKit
import SceneKit
import FontAwesomeKit

class TetrisMovementHandler {
    let config: TetrisConfig
    let position: SCNVector3
    let cell: Float
    let arrowLength = Float(3)
    
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
        let icon = try! FAKFontAwesome(identifier: "fa-chevron-up", size: 15)
        icon.addAttributes([NSAttributedStringKey.foregroundColor: UIColor.white])
        let image = icon.image(with: CGSize(width: 10, height: 10))
        
        let centerX = (Float(config.length - 1) / 2) * cell
        let centerZ = (Float(config.length - 1) / 2) * cell
        for (i, signX, signZ) in [(0, Float(0), Float(-1)), (1, Float(-1), Float(0)), (2, Float(0), Float(1)), (3, Float(1), Float(0))] {
            let arrowMaterial = SCNMaterial()
            arrowMaterial.diffuse.contents = image
            arrowMaterial.diffuse.contentsTransform = SCNMatrix4Mult(SCNMatrix4Mult(SCNMatrix4MakeTranslation(-0.5, -0.5, 0), SCNMatrix4MakeRotation(Float(i) * (Float.pi / 2), 0, 0, 1)), SCNMatrix4MakeTranslation(0.5, 0.5, 0))
        
            let arrowPlane = SCNPlane(width: CGFloat(arrowLength) * CGFloat(cell), height: CGFloat(arrowLength) * CGFloat(cell))
            arrowPlane.firstMaterial = arrowMaterial
            
            let deltaX = signX * ((Float(config.length) + arrowLength) / 2) * cell
            let deltaZ = signZ * ((Float(config.length) + arrowLength) / 2) * cell
            let arrowNode = SCNNode(geometry: arrowPlane)
            arrowNode.position = SCNVector3(centerX + deltaX, -0.5 * cell, centerZ + deltaZ)
            arrowNode.rotation = SCNVector4(1, 0, 0, -Float.pi / 2)
            parentNode.addChildNode(arrowNode)
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
