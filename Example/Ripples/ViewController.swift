//
//  ViewController.swift
//  Ripples
//
//  Created by catchzeng on 08/01/2018.
//  Copyright (c) 2018 catchzeng. All rights reserved.
//

import UIKit
import Ripples

class ViewController: UIViewController {
    let ripple = Ripples()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ripple.radius = 300
        ripple.rippleCount = 5
        view.layer.addSublayer(ripple)
        
        ripple.start()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ripple.position = view.center
    }
}

