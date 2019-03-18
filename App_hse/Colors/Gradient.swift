//
//  Gradient.swift
//  App_hse
//
//  Created by Vladislava on 31/01/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import Foundation
import UIKit

extension  UIView {
    
    func setGradientBackground(colorOne: UIColor, colorTwo: UIColor) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.3, 0.7]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
