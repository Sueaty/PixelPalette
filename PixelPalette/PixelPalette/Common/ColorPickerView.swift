//
//  ColorPickerView.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/08/02.
//

import UIKit
import CoreGraphics

final class ColorPickerView: UIView {
    
    var lastLocation = CGPoint(x: 0, y: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                          action: #selector(panColorPicker(_:)))
        self.gestureRecognizers = [panGestureRecognizer]
        
        self.bounds.size = CGSize(width: 30, height: 30)
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.layer.isOpaque = false
        self.layer.borderWidth = 5
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = 15
        
        self.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastLocation = self.center
    }
    
}

private extension ColorPickerView {
    
    @objc func panColorPicker(_ sender: UIPanGestureRecognizer) {
        guard let superview = superview else { return }
        let translation = sender.translation(in: self.superview)

        let minCenterX = frame.size.width / 2
        let minCenterY = frame.size.height / 2
        let maxCenterX = superview.frame.width - frame.size.width / 2
        let maxCenterY = superview.frame.height - frame.size.height / 2
        
        let newCenterX = center.x + translation.x
        let newCenterY = center.y + translation.y
        
        center.x = min(maxCenterX, max(minCenterX, newCenterX))
        center.y = min(maxCenterY, max(minCenterY, newCenterY))
        
        sender.setTranslation(.zero, in: self) // does this slow everything down?
    }
    
}
