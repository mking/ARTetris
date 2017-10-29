//
//  TetrisOverlay.swift
//  ARTetris
//
//  Created by mking on 10/28/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import SceneKit

class TetrisOverlay {
    let scoreLabel: UILabel!
    
    init(scoreLabel: UILabel) {
        self.scoreLabel = scoreLabel
    }
    
    func setScore(score: Int) {
        self.scoreLabel.text = "\(score)"
    }
}
