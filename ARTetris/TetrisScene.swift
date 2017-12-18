//
//  TetrisScene.swift
//  ARTetris
//
//  Created by Yuri Strot on 6/29/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation
import SceneKit

class TetrisScene {
	
	private static let colors : [UIColor] = [
		UIColor(red:1.00, green:0.23, blue:0.19, alpha:1.0),
		UIColor(red:1.00, green:0.18, blue:0.33, alpha:1.0),
		UIColor(red:1.00, green:0.58, blue:0.00, alpha:1.0),
		UIColor(red:1.00, green:0.80, blue:0.00, alpha:1.0),
		UIColor(red:0.35, green:0.34, blue:0.84, alpha:1.0),
		UIColor(red:0.20, green:0.67, blue:0.86, alpha:1.0),
		UIColor(red:0.56, green:0.56, blue:0.58, alpha:1.0)]
	
	private static let wellColor = UIColor(red:0, green:0, blue:0, alpha:0.0)
    private static let sideWellColor = UIColor(red:0, green:0, blue:0, alpha:0.1)
    private static let projectionColor = UIColor(red:0, green:0, blue:0.2, alpha:0.2)
	private static let floorColor = UIColor(red:0, green:0, blue:0, alpha:0.3)
	private static let scoresColor = UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.0)
	private static let titleColor = UIColor(red:0.35, green:0.34, blue:0.84, alpha:1.0)
	
	private let cell: Float
    private let lineWidth: Float
	
	private let config: TetrisConfig
	private let scene: SCNScene
    private var gameNode: SCNNode!
    private var pinchNode: SCNNode!
	private let x: Float
	private let y: Float
	private let z: Float
	
    private var enableProjection: Bool
    private var blocksByLine: [[SCNNode]] = []
    private var blocksByName = [String: SCNNode]()
	private var recent: SCNNode!
    private var projection: SCNNode!
	private var frame: SCNNode!
    private var movementHandler: TetrisMovementHandler
    private var restartButton: UIButton!
    private var showMessage: ((Int, Int) -> Void)

    init(_ config: TetrisConfig, _ scene: SCNScene, _ movementHandler: TetrisMovementHandler, _ x: Float, _ y: Float, _ z: Float, _ cell: Float, _ restartButton: UIButton!, _ lineWidth: Float, _ showMessage: @escaping ((Int, Int) -> Void)) {
		self.config = config
		self.scene = scene
        self.x = x
		self.y = y
		self.z = z
        self.enableProjection = true
        self.cell = cell
        self.restartButton = restartButton
        self.gameNode = SCNNode()
        self.movementHandler = movementHandler
        self.lineWidth = lineWidth
        self.showMessage = showMessage
        self.frame = createWellFrame(config.width, config.height, config.depth)
//        gameNode.addChildNode(self.frame)
//        gameNode.addChildNode(createBoard())
//        scene.rootNode.addChildNode(gameNode)
        self.pinchNode = createPinchNode()
        scene.rootNode.addChildNode(pinchNode)
	}
    
    func restart() {
        pinchNode.removeFromParentNode()
        gameNode = SCNNode()
        frame = createWellFrame(config.width, config.height, config.depth)
        pinchNode = createPinchNode()
        scene.rootNode.addChildNode(pinchNode)
    }
    
    func createPinchNode() -> SCNNode {
        let cubeGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.0)
        let cubeMaterial = SCNMaterial.material(withDiffuse: UIColor.red)
        cubeGeometry.firstMaterial = cubeMaterial
        let cubeNode = SCNNode(geometry: cubeGeometry)
        cubeNode.position = SCNVector3(x: self.x, y: self.y, z: self.z)
        
        let light = SCNLight()
        light.type = .omni
        light.color = UIColor.white
        
        let lightNode = SCNNode()
        lightNode.position = SCNVector3(x: 0.0, y: Float(config.height) * cell, z: 0.0)
        lightNode.light = light
        
        let centeringNode = SCNNode()
        centeringNode.position = SCNVector3(x: -(Float(config.length) / 2.0) * cell, y: 0.0, z: -(Float(config.length) / 2.0) * cell)
        centeringNode.addChildNode(self.frame)
        centeringNode.addChildNode(self.gameNode)
        centeringNode.addChildNode(lightNode)
        movementHandler.addArrows(parentNode: centeringNode)
        
        let pinchNode = SCNNode()
        pinchNode.position = SCNVector3(x: self.x, y: self.y, z: self.z)
//        pinchNode.addChildNode(cubeNode)
        pinchNode.addChildNode(centeringNode)
        return pinchNode
    }
    
    // Show the board (the bottom of the well)
    func createBoard() -> SCNNode {
        let boardMaterial = SCNMaterial.material(withDiffuse: UIColor.blue)
        let boardGeometry = SCNPlane(width: CGFloat(config.width) * CGFloat(cell), height: CGFloat(config.depth) * CGFloat(cell))
        boardGeometry.firstMaterial = boardMaterial
        let boardNode = SCNNode(geometry: boardGeometry)
        // Place the board in the center of the well
        boardNode.position = SCNVector3(x + ((Float(config.width) / 2) * cell), y, z + ((Float(config.depth) / 2) * cell))
        // Rotate the board to be parallel to the floor
        boardNode.rotation = SCNVector4(1, 0, 0, -Float.pi / 2)
        
        let markerMaterial = SCNMaterial.material(withDiffuse: UIColor.yellow)
        let markerGeometry = SCNPlane(width: CGFloat(config.width) * CGFloat(cell), height: CGFloat(cell) / 4)
        markerGeometry.firstMaterial = markerMaterial
        let markerNode = SCNNode(geometry: markerGeometry)
        // Place marker at the bottom in the z direction
        markerNode.position = SCNVector3(x + ((Float(config.width) / 2) * cell), y, z + (Float(config.depth) * cell))
        markerNode.rotation = SCNVector4(1, 0, 0, -Float.pi / 2)
        
        let node = SCNNode()
        node.addChildNode(boardNode)
        node.addChildNode(markerNode)
        return node
    }
	
	func show(_ current: TetrisState) {
        // recent holds the current dropping tetronimo (its related scene nodes).
        // Every time we rerender the TetrisState, we remove the old recent and replace it with a new one.
		recent?.removeFromParentNode()
		recent = SCNNode()
		let tetromino = current.tetromino()
		for i in 0...3 {
			recent.addChildNode(block(current, tetromino.x(i), tetromino.y(i), tetromino.z(i)))
		}
		gameNode.addChildNode(recent)

        // reset frame to be transparent
        for node in self.frame.childNodes {
            node.geometry?.firstMaterial?.diffuse.contents = TetrisScene.wellColor
        }
        showFloor()
	}
	
    func removeProjection() {
        projection?.removeFromParentNode()
        self.disableProjectionNode()
    }

    func disableProjectionNode() {
        enableProjection = false
    }
    func enableProjectionNode() {
        enableProjection = true
    }

    func showProjection(_ project: TetrisState) {
        if (enableProjection) {
            projection?.removeFromParentNode()
            projection = SCNNode()
            let tetromino = project.tetromino()
            for i in 0...3 {
                projection.addChildNode(blockWithColor(project, tetromino.x(i), tetromino.y(i), tetromino.z(i), TetrisScene.projectionColor))
            }
            gameNode.addChildNode(projection)
        }
    }

	func addToWell(_ current: TetrisState) -> [String] {
        projection?.removeFromParentNode()
		recent?.removeFromParentNode()
		let tetromino = current.tetromino()
        var names = [String]()
		for i in 0...3 {
            // Here we permanently add the tetronimo to the well.
			let box = block(current, tetromino.x(i), tetromino.y(i), tetromino.z(i))
			gameNode.addChildNode(box)
			let row = tetromino.y(i) + current.y
			while(blocksByLine.count <= row) {
				blocksByLine.append([])
			}
			blocksByLine[row].append(box)
            blocksByName[box.name!] = box
            names.append(box.name!)
		}
        return names
	}
	
	func removeLines(_ transition: TetrisMatrixTransition, _ scores: Int) -> CFTimeInterval {
		let time = 0.2
		// hide blocks in removed lines
		for name in transition.removed {
			if let block = blocksByName[name] {
				animate(block, "opacity", from: 1, to: 0, during: time)
			}
		}
		Timer.scheduledTimer(withTimeInterval: time, repeats: false) { _ in
//            self.showLinesScores(Float(lines.first!), scores)
            
            // drop blocks down to fill empty spaces of removed lines
            for t in transition.heightTransitions() {
                if let block = self.blocksByName[t.name] {
                    let oldY = block.position.y
                    let newY = (Float(t.newY) - 0.5) * self.cell
                    self.animate(block, "position.y", from: oldY, to: newY, during: time)
                }
            }
            
			// remove filled lines from the scene
			for name in transition.removed {
                if let block = self.blocksByName[name] {
					block.removeFromParentNode()
                    self.blocksByName.removeValue(forKey: block.name!)
                }
			}
		}
		return time * 2
	}
	
	func drop(from: TetrisState, to: TetrisState) -> CFTimeInterval {
		// use animation time from 0.1 to 0.4 seconds depending on distance
		let delta = from.y - to.y
		let percent = Double(delta - 1) / Double(config.height - 1)
		let time = percent * 0.3 + 0.1
		animate(recent, "position.y", from: 0, to: Float(-delta) * cell, during: time)
		return time
	}
	
    func showGameOver(_ scores: Int) {
        let topScore = TetrisDefaults.topScore
        print ("gameover, the previous top score: ", topScore)
        print ("gameover, current score: ", scores)
        if (scores > topScore) {
            TetrisDefaults.topScore = scores
            showMessage(scores, topScore)
        }
        restartButton.isHidden = false
        
		// Remove well frame from the scene
		self.frame.removeFromParentNode()
		
		// Use Moon gravity to make effect slower
		scene.physicsWorld.gravity = SCNVector3Make(0, -1.6, 0)
		
		// SCNPlanes are vertically oriented in their local coordinate space
		//let matrix = SCNMatrix4Mult(SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0), translate(0, 0))
		let floor = createNode(SCNPlane(width: 10, height: 10), TetrisScene.floorColor)
        floor.position = translate(0, 0)
        floor.rotation = SCNVector4(1, 0, 0, -Float.pi / 2)
		floor.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
		gameNode.addChildNode(floor)
		
		for i in 0..<blocksByLine.count {
			// Apply little impulse to all boxes in a random direction.
			// This will force our Tetris "pyramid" to break up.
			let z = Float((Int(arc4random_uniform(3)) - 1) * i) * -0.01
			let x = Float((Int(arc4random_uniform(3)) - 1) * i) * -0.01
			let direction = SCNVector3Make(x, 0, z)
			for item in blocksByLine[i] {
				item.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
				// use 0.9 angular damping to prevents boxes from rotating like a crazy
				item.physicsBody!.angularDamping = 0.9
				item.physicsBody!.applyForce(direction, asImpulse: true)
			}
		}
		Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
//            self.showFinalScores(scores)
		}
	}
	
	private func showLinesScores(_ line: Float, _ scores: Int) {
		let node = createNode(text("+\(scores)"), TetrisScene.scoresColor)
        node.position = translate(5, line, 2)
        node.setUniformScale(0.001)
		let y = node.position.y
		animate(node, "position.y", from: y, to: y + cell * 4, during: 2)
		animate(node, "opacity", from: 1, to: 0, during: 2)
		gameNode.addChildNode(node)
	}
	
	private func showFinalScores(_ scores: Int) {
		let x = Float(config.width / 2)
		let y = Float(config.height / 2)
		let node = createNode(text("Scores: \(scores)"), TetrisScene.titleColor)
        node.position = translate(x, y, 0)
        node.setUniformScale(0.003)
		gameNode.addChildNode(node)
	}
	
    private func createWellFrame(_ width: Int, _ height: Int, _ depth: Int) -> SCNNode {
		let node = SCNNode()
        // x direction lines
        for yIndex in 0...height {
            for zIndex in 0...depth {
                addLine(to: node, Float(width) * cell, lineWidth, lineWidth, 0, Float(yIndex), Float(zIndex))
            }
        }
        
        // z direction lines
        for yIndex in 0...height {
            for xIndex in 0...width {
                addLine(to: node, lineWidth, lineWidth, Float(depth) * cell, Float(xIndex), Float(yIndex), Float(depth))
            }
        }
        
        // y direction lines
        for xIndex in 0...width {
            for zIndex in 0...depth {
                addLine(to: node, lineWidth, Float(height) * cell, lineWidth, Float(xIndex), 0, Float(zIndex))
            }
        }
        
		return node
	}
	
    // need to be align with createWellFrame function's implementation
    // 1 for left; 2 for right; 3 for back; 4 for front
    func showSideWall(_ side: Int) {
        let X = config.width + 1
        let Y = config.height + 1
        let Z = config.depth + 1

        switch side {
        case 1:
            // left
            for i in stride(from: Z * Y, to: Z * Y + X * Y, by: X) {
                self.frame.childNodes[i].geometry?.firstMaterial?.diffuse.contents = TetrisScene.sideWellColor
            }
            for i in stride(from: Z * Y + X * Y, to: Z * Y + X * Y + Z, by: 1) {
                self.frame.childNodes[i].geometry?.firstMaterial?.diffuse.contents = TetrisScene.sideWellColor
            }
        case 2:
            // right
            for i in stride(from: Z * Y + X - 1, to: Z * Y + X * Y , by: X) {
                self.frame.childNodes[i].geometry?.firstMaterial?.diffuse.contents = TetrisScene.sideWellColor
            }
            for i in stride(from: Z * Y + X * Y + Z * (X - 1), to: Z * Y + X * Y + Z * X, by: 1) {
                self.frame.childNodes[i].geometry?.firstMaterial?.diffuse.contents = TetrisScene.sideWellColor
            }
        case 3:
            // back
            for i in stride(from: 0, to: Z * Y, by: Z) {
                self.frame.childNodes[i].geometry?.firstMaterial?.diffuse.contents = TetrisScene.sideWellColor
            }
            for i in stride(from: Z * Y + X * Y, to: Z * Y + X * Y + Z * X, by: Z) {
                self.frame.childNodes[i].geometry?.firstMaterial?.diffuse.contents = TetrisScene.sideWellColor
            }
        case 4:
            // front
            for i in stride(from: Z - 1, to: Z * Y, by: Z) {
                self.frame.childNodes[i].geometry?.firstMaterial?.diffuse.contents = TetrisScene.sideWellColor
            }
            for i in stride(from: Z * Y + X * Y + Z - 1, to: Z * Y + X * Y + Z * X, by: Z) {
                self.frame.childNodes[i].geometry?.firstMaterial?.diffuse.contents = TetrisScene.sideWellColor
            }
        default:
            break
        }
    }

    func showFloor() {
        let X = config.width + 1
        let Y = config.height + 1
        let Z = config.depth + 1

        for i in stride(from: 0, to: Z, by: 1) {
            self.frame.childNodes[i].geometry?.firstMaterial?.diffuse.contents = TetrisScene.sideWellColor
        }
        for i in stride(from: Z * Y, to: Z * Y + X, by: 1) {
            self.frame.childNodes[i].geometry?.firstMaterial?.diffuse.contents = TetrisScene.sideWellColor
        }
    }

	private func text(_ string: String) -> SCNText {
		let text = SCNText(string: string, extrusionDepth: 1)
		text.font = UIFont.systemFont(ofSize: 20)
		return text
	}
	
    private func block(_ state: TetrisState, _ x: Int, _ y: Int, _ z: Int) -> SCNNode {
		let cell = cg(self.cell)
		let box = SCNBox(width: cell, height: cell, length: cell, chamferRadius: cell / 6)
//        let matrix = translate(Float(state.x + x), Float(state.y + y) - 0.5, Float(state.z + z))
		let node = createNode(box, TetrisScene.colors[state.index])
        node.position = translate(Float(state.x + x), Float(state.y + y) - 0.5, Float(state.z + z))
        node.name = UUID().uuidString
        return node
	}
	
    private func blockWithColor(_ state: TetrisState, _ x: Int, _ y: Int, _ z: Int, _ color: UIColor) -> SCNNode {
        let cell = cg(self.cell)
        let box = SCNBox(width: cell, height: cell, length: cell, chamferRadius: cell / 6)
        let node = createNode(box, color)
        node.position = translate(Float(state.x + x), Float(state.y + y) - 0.5, Float(state.z + z))
        return node
    }

	private func addLine(to node: SCNNode, _ w: Float, _ h: Float, _ l: Float, _ x: Float, _ y: Float, _ z: Float) {
		let lineGeometry = SCNBox(width: cg(w), height: cg(h), length: cg(l), chamferRadius: 0)
        lineGeometry.firstMaterial = SCNMaterial.material(withDiffuse: TetrisScene.wellColor)
        let lineNode = SCNNode(geometry: lineGeometry)
        lineNode.position = SCNVector3(((x - 0.5) * cell) + (w / 2), ((y - 0.5) * cell) + (h / 2), ((z - 0.5) * cell) + (-l / 2))
        node.addChildNode(lineNode)
//        let matrix = SCNMatrix4Translate(translate(x - 0.5, y, z - 0.5), w / 2, h / 2, -l / 2)
//        node.addChildNode(createNode(line, matrix, TetrisScene.wellColor))
	}
	
	private func animate(_ node: SCNNode, _ path: String, from: Any, to: Any, during: CFTimeInterval) {
		let animation = CABasicAnimation(keyPath: path)
		animation.fromValue = from
		animation.toValue = to
		animation.duration = during
		animation.fillMode = kCAFillModeForwards
		animation.isRemovedOnCompletion = false
		node.addAnimation(animation, forKey: nil)
	}
	
//    private func createNode(_ geometry: SCNGeometry, _ matrix: SCNMatrix4, _ color: UIColor) -> SCNNode {
//        return createNode(geometry, color)
//    }
    
	private func createNode(_ geometry: SCNGeometry, _ color: UIColor) -> SCNNode {
		let material = SCNMaterial()
		material.diffuse.contents = color
		// use the same material for all geometry elements
		geometry.firstMaterial = material
		let node = SCNNode(geometry: geometry)
		//node.transform = matrix
		return node
	}
	
	private func translate(_ x: Float, _ y: Float, _ z: Float = 0) -> SCNVector3 {
        return SCNVector3(x * cell, y * cell, z * cell)
//        return SCNVector3(self.x + x * cell, self.y + y * cell, self.z + z * cell)
	}
	
	private func cg(_ f: Float) -> CGFloat { return CGFloat(f) }
	
    var scale: Float {
        get {
            return pinchNode.scale.x
        }
        
        set {
            pinchNode.setUniformScale(min(2.0, max(0.5, newValue)))
        }
    }
    
    var rotation: Float {
        get {
            return pinchNode.eulerAngles.y
        }
        
        set {
            pinchNode.eulerAngles = SCNVector3(x: pinchNode.eulerAngles.x, y: newValue, z: pinchNode.eulerAngles.z)
        }
    }
}

extension SCNMatrix4 {
	func scale(_ s: Float) -> SCNMatrix4 { return SCNMatrix4Scale(self, s, s, s) }
}
