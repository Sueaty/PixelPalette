//
//  BaseView.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/08/23.
//

import UIKit

class BaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setInit()
        setViewHierarchy()
        setViewConstraint()
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    }
}

