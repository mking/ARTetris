//
//  TetrisDefaults.swift
//  ARTetris
//
//  Created by matt2 on 12/17/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation

class TetrisDefaults {
    static var topScore: Int {
        get {
            return UserDefaults.standard.integer(forKey: "topScore") 
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "topScore")
        }
    }
    
    static var showTutorial: Bool {
        get {
            if UserDefaults.standard.object(forKey: "showTutorial") == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: "showTutorial")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "showTutorial")
        }
    }
}
