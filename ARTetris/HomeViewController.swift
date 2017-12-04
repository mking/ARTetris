//
//  HomeViewController.swift
//  ARTetris
//
//  Created by Chunyue Du on 11/19/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var topScoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let topScore = UserDefaults.standard.object(forKey: "topScore")
        if (topScore == nil) {
            UserDefaults.standard.set(0, forKey: "topScore")
        }
        updateTopScore()

        navigationController!.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTopScore()
    }
    
    func updateTopScore() {
        self.topScoreLabel.text = "Top score: \(UserDefaults.standard.integer(forKey: "topScore"))"
    }
}
