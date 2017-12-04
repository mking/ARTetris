//
//  HomeViewController.swift
//  ARTetris
//
//  Created by Chunyue Du on 11/19/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    override func viewDidLoad() {
        let topScore = UserDefaults.standard.object(forKey: "topScore")
        if (topScore == nil) {
            UserDefaults.standard.set(0, forKey: "topScore")
        }
        self.TopScoreLabel.text = "Top score:" + String(UserDefaults.standard.integer(forKey: "topScore"))
        super.viewDidLoad()
        navigationController!.isNavigationBarHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        self.TopScoreLabel.text = "Top score:" + String(UserDefaults.standard.integer(forKey: "topScore"))
    }
    @IBOutlet weak var TopScoreLabel: UILabel!
}
