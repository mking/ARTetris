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
	
	private static let wellColor = UIColor(red:0, green:0, blue:0, alpha:0.3)
	private static let floorColor = UIColor(red:0, green:0, blue:0, alpha:0)
	private static let scoresColor = UIColor(red:0.30, green:0.85, blue:0.39, alpha:1.0)
	private static let titleColor = UIColor(red:0.35, green:0.34, blue:0.84, alpha:1.0)
	
	private let cell: Float = 0.03
	
	private let config: TetrisConfig
	private let scene: SCNScene
	private let x: Float
	private let y: Float
	private let z: Float
	
	private var blocksByLine: [[SCNNode]] = []
	private var recent: SCNNode!
	private var frame: SCNNode!
	
	init(_ config: TetrisConfig, _ scene: SCNScene, _ x: Float, _ y: Float, _ z: Float) {
		self.config = config
		self.scene = scene
        self.x = x
		self.y = y
		self.z = z
		self.frame = createWellFrame(config.width, config.height, config.depth)
		scene.rootNode.addChildNode(self.frame)
        scene.rootNode.addChildNode(createBoard())
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
        markerNode.position = SCNVector3(x + ((Float(config.width) / 2) * cell), y, z)
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
		scene.rootNode.addChildNode(recent)
	}
	
	func addToWell(_ current: TetrisState) {
		recent?.removeFromParentNode()
		let tetromino = current.tetromino()
		for i in 0...3 {
            // Here we permanently add the tetronimo to the well.
			let box = block(current, tetromino.x(i), tetromino.y(i), tetromino.z(i))
			scene.rootNode.addChildNode(box)
			let row = tetromino.y(i) + current.y
			while(blocksByLine.count <= row) {
				blocksByLine.append([])
			}
			blocksByLine[row].append(box)
		}
	}
	
	func removeLines(_ lines: [Int], _ scores: Int) -> CFTimeInterval {
		let time = 0.2
		// hide blocks in removed lines
		for line in lines {
			for block in blocksByLine[line] {
				animate(block, "opacity", from: 1, to: 0, during: time)
			}
		}
		Timer.scheduledTimer(withTimeInterval: time, repeats: false) { _ in
			self.showLinesScores(Float(lines.first!), scores)
			// drop blocks down to fill empty spaces of removed lines
			for (index, line) in lines.reversed().enumerated() {
				let nextLine = index + 1 < lines.count ? lines[index + 1] : self.blocksByLine.count
				if (nextLine > line + 1) {
					for j in line + 1..<nextLine {
						for block in self.blocksByLine[j] {
							let y1 = self.y + Float(j) * self.cell - self.cell / 2
							let y2 = y1 - self.cell * Float(index + 1)
							self.animate(block, "position.y", from: y1, to: y2, during: time)
						}
					}
				}
			}
			// remove filled lines from the scene
			for line in lines {
				for block in self.blocksByLine[line] {
					block.removeFromParentNode()
				}
				self.blocksByLine.remove(at: line)
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
		// Remove well frame from the scene
		self.frame.removeFromParentNode()
		
		// Use Moon gravity to make effect slower
		scene.physicsWorld.gravity = SCNVector3Make(0, -1.6, 0)
		
		// SCNPlanes are vertically oriented in their local coordinate space
		let matrix = SCNMatrix4Mult(SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0), translate(0, 0))
		let floor = createNode(SCNPlane(width: 10, height: 10), matrix, TetrisScene.floorColor)
		floor.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
		scene.rootNode.addChildNode(floor)
		
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
			self.showFinalScores(scores)
		}
	}
	
	private func showLinesScores(_ line: Float, _ scores: Int) {
		let node = createNode(text("+\(scores)"), translate(5, line, 2).scale(0.001), TetrisScene.scoresColor)
		let y = node.position.y
		animate(node, "position.y", from: y, to: y + cell * 4, during: 2)
		animate(node, "opacity", from: 1, to: 0, during: 2)
		self.scene.rootNode.addChildNode(node)
	}
	
	private func showFinalScores(_ scores: Int) {
		let x = Float(config.width / 2)
		let y = Float(config.height / 2)
		let node = createNode(text("Scores: \(scores)"), translate(x, y).scale(0.003), TetrisScene.titleColor)
		self.scene.rootNode.addChildNode(node)
	}
	
    private func createWellFrame(_ width: Int, _ height: Int, _ depth: Int) -> SCNNode {
		let node = SCNNode()
        
        // x direction lines
        for yIndex in 0...height {
            for zIndex in 0...depth {
                addLine(to: node, Float(width) * cell, Float(0.001), Float(0.001), 0, Float(yIndex), Float(zIndex))
            }
        }
        
        // z direction lines
        for yIndex in 0...height {
            for xIndex in 0...width {
                addLine(to: node, Float(0.001), Float(0.001), Float(depth) * cell, Float(xIndex), Float(yIndex), Float(depth))
            }
        }
        
        // y direction lines
        for xIndex in 0...width {
            for zIndex in 0...depth {
                addLine(to: node, Float(0.001), Float(height) * cell, Float(0.001), Float(xIndex), 0, Float(zIndex))
            }
        }
        
		return node
	}
	
	private func text(_ string: String) -> SCNText {
		let text = SCNText(string: string, extrusionDepth: 1)
		text.font = UIFont.systemFont(ofSize: 20)
		return text
	}
	
    private func block(_ state: TetrisState, _ x: Int, _ y: Int, _ z: Int) -> SCNNode {
		let cell = cg(self.cell)
		let box = SCNBox(width: cell, height: cell, length: cell, chamferRadius: cell / 10)
		let matrix = translate(Float(state.x + x), Float(state.y + y) - 0.5, Float(state.z + z))
		return createNode(box, matrix, TetrisScene.colors[state.index])
	}
	
	private func addLine(to node: SCNNode, _ w: Float, _ h: Float, _ l: Float, _ x: Float, _ y: Float, _ z: Float) {
		let line = SCNBox(width: cg(w), height: cg(h), length: cg(l), chamferRadius: 0)
		let matrix = SCNMatrix4Translate(translate(x - 0.5, y, z - 0.5), w / 2, h / 2, -l / 2)
		node.addChildNode(createNode(line, matrix, TetrisScene.wellColor))
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
	
	private func createNode(_ geometry: SCNGeometry, _ matrix: SCNMatrix4, _ color: UIColor) -> SCNNode {
		let material = SCNMaterial()
		material.diffuse.contents = color
		// use the same material for all geometry elements
		geometry.firstMaterial = material
		let node = SCNNode(geometry: geometry)
		node.transform = matrix
		return node
	}
	
	private func translate(_ x: Float, _ y: Float, _ z: Float = 0) -> SCNMatrix4 {
		return SCNMatrix4MakeTranslation(self.x + x * cell, self.y + y * cell, self.z + z * cell)
	}
	
	private func cg(_ f: Float) -> CGFloat { return CGFloat(f) }
	
}

extension SCNMatrix4 {
	func scale(_ s: Float) -> SCNMatrix4 { return SCNMatrix4Scale(self, s, s, s) }
}
