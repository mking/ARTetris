//
//  TetrisEngine.swift
//  ARTetris
//
//  Created by Yuri Strot on 6/30/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation
import SceneKit

/** Tetris game enigne */
class TetrisEngine {
	
	let config: TetrisConfig
	let well: TetrisWell
	let scene: TetrisScene
	
	var current: TetrisState
	var timer: Timer?
	var scores = 0
	
	init(_ config: TetrisConfig, _ well: TetrisWell, _ scene: TetrisScene) {
		self.config = config
		self.well = well
		self.scene = scene
        self.current = .random(config)
        self.setState(current)
		startTimer()
	}
	
	func rotateX(_ angle: Int) { setState(current.rotateX(angle)) }
    
    func rotateY(_ angle: Int) { setState(current.rotateY(angle)) }
    
    func forward() { setState(current.forward()) }
    
    func backward() { setState(current.backward()) }
	
	func left() { setState(current.left()) }
	
	func right() { setState(current.right()) }
	
	func drop() {
		animate(onComplete: addCurrentTetrominoToWell) {
			let initial = current
			while(!well.hasCollision(current.down())) {
				current = current.down()
			}
			return scene.drop(from: initial, to: current)
		}
	}
	
    func getProjection () -> TetrisState {
        var curCopy = current
        while(!well.hasCollision(curCopy.down())) {
            curCopy = curCopy.down()
        }

        return curCopy
    }

	private func setState(_ state: TetrisState) {
        scene.showSideWall(well.hasSideCollision(state))

		if (!well.hasCollision(state)) {
			self.current = state
			scene.show(state)
            let project = self.getProjection()
            scene.showProjection(project)
		}
	}
	
	private func addCurrentTetrominoToWell() {
		let names = scene.addToWell(current)
        well.add(current, names)
        
		let transition = well.clearFilledLines()
		if (transition.isEmpty()) {
			nextTetromino()
		} else {
			animate(onComplete: nextTetromino) {
				let scores = getScores(transition.score)
				self.scores += scores
				return scene.removeLines(transition, scores)
			}
		}
	}
	
	private func nextTetromino() {
        repeat {
            current = .random(config)
        } while (well.hasSideCollision(current) > 0)
        
        if (well.hasCollision(current)) {
            stopTimer()
            scene.showGameOver(scores)
        } else {
			scene.show(current)
        }
	}
	
	private func getScores(_ lineCount: Int) -> Int {
		switch lineCount {
		case 1:
			return 100
		case 2:
			return 300
		case 3:
			return 500
		default:
			return 800
		}
	}
	
	private func animate(onComplete: @escaping () -> Void, block: () -> CFTimeInterval) {
		self.stopTimer()
		Timer.scheduledTimer(withTimeInterval: block(), repeats: false) { _ in
			self.startTimer()
			onComplete()
		}
	}
	
	private func startTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // When the current tetromino reaches the bottom, add it to the well.
			let down = self.current.down()
			if (self.well.hasCollision(down)) {
				self.addCurrentTetrominoToWell()
			} else {
                self.setState(down)
			}
		}
	}
	
	private func stopTimer() {
		timer?.invalidate()
		timer = nil
	}
	
}
