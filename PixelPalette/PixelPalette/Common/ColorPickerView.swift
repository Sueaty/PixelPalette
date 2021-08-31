//
//  ColorPickerView.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/08/02.
//

import UIKit
import CoreGraphics

protocol ColorPickerDelegate {
    func didMoveImagePicker(_ view: ColorPickerView, didMoveImagePicker location: CGPoint)
}

final class ColorPickerView: UIView {
    
    // MARK:- Properties
    var delegate: ColorPickerDelegate?
    var lastLocation = CGPoint(x: 0, y: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panColorPicker(_:)))
        addGestureRecognizer(panGestureRecognizer)
        
        bounds.size = CGSize(width: 16, height: 16)
        
        layer.borderWidth = 3
        layer.cornerRadius = 8
        layer.isOpaque = false
        layer.borderColor = UIColor.black.cgColor
        layer.backgroundColor = UIColor.clear.cgColor
        
        isHidden = true
        isUserInteractionEnabled = true
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
        if sender.state == .began || sender.state == .changed {
            bounds.size = CGSize(width: 20, height: 20)
            layer.cornerRadius = 10
        } else if sender.state == .ended {
            bounds.size = CGSize(width: 14, height: 14)
            layer.cornerRadius = 7
        }

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

        sender.setTranslation(.zero, in: self)
        delegate?.didMoveImagePicker(self, didMoveImagePicker: CGPoint(x: center.x,
                                                                       y: center.y))
    }
    
}
