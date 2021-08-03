//
//  ColorPickerView.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/08/02.
//

import UIKit

final class ColorPickerView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.frame = CGRect(origin: CGPoint(x: 0, y: 0),
                            size: CGSize(width: 20, height: 20))
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.layer.isOpaque = false
        self.layer.borderWidth = 5
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
