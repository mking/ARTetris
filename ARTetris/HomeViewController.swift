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
    
    @IBAction func handleHelp(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Tutorial", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "tutorial", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "About", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "about", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { _ in
            let alert = UIAlertController(title: nil, message: "Are you sure you want to clear saved data (including high score)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { _ in
                TetrisDefaults.topScore = 0
                TetrisDefaults.showTutorial = true
                self.updateTopScore()
            }))
            self.present(alert, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
