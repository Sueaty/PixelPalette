//
//  BaseViewController.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/07/28.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setInit()
        setViewHierarchy()
        setViewConstraint()
        setUI()
    }
    
    func setInit() {
        // override here
    }
    
    func setViewHierarchy() {
        // override here
    }
    
    func setViewConstraint() {
        // override here
    }
    
    func setUI() {
        // override here
        view.backgroundColor = UIColor(hexString: "#4d4848")
        tabBarController?.tabBar.barTintColor = UIColor(hexString: "#4d4848")
    }
    
}
