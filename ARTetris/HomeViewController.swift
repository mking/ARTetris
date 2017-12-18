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

        updateTopScore()

        navigationController!.isNavigationBarHidden = true
        
        if TetrisDefaults.showTutorial {
            performSegue(withIdentifier: "tutorial", sender: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTopScore()
    }
    
    func updateTopScore() {
        self.topScoreLabel.text = "Top score: \(TetrisDefaults.topScore)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tutorial" {
            TetrisDefaults.showTutorial = true
        }
    }
    
    @IBAction func handleReset(_ sender: UIButton) {
        TetrisDefaults.topScore = 0
        TetrisDefaults.showTutorial = true
        let alert = UIAlertController(title: "Reset", message: "High score and tutorial were reset.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true)
        updateTopScore()
    }
}
