//
//  PadView.swift
//  ARTetris
//
//  Created by mking on 8/13/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import UIKit

class PadView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    private func setup() {
        layer.borderColor = #colorLiteral(red: 1, green: 0.8288275599, blue: 0, alpha: 1).cgColor
        layer.borderWidth = 1
    }
}
