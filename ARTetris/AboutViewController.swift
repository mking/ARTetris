//
//  AboutViewController.swift
//  ARTetris
//
//  Created by matt2 on 12/17/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    @IBAction func handleMail(_ sender: UIButton) {
        UIApplication.shared.open(URL(string: "mailto:arrussianblocks@gmail.com")!)
    }
    
    @IBAction func handleDone(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
