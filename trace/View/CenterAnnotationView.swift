//
//  CenterAnnotationView.swift
//  trace
//
//  Created by Justin Tey on 02/08/2019.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit


class CenterAnnotationView: UIImageView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}


