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
    
    var delegate: ColorPickerDelegate?
    var lastLocation = CGPoint(x: 0, y: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                          action: #selector(panColorPicker(_:)))
        gestureRecognizers = [panGestureRecognizer]
        
        bounds.size = CGSize(width: 20, height: 20)
        layer.backgroundColor = UIColor.clear.cgColor
        layer.isOpaque = false
        layer.borderWidth = 5
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 10
        
        isHidden = true
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
            bounds.size = CGSize(width: 40, height: 40)
            layer.cornerRadius = 20
        } else if sender.state == .ended {
            bounds.size = CGSize(width: 20, height: 20)
            layer.cornerRadius = 10
        }
        
        guard let superview = superview else { return }
        let translation = sender.translation(in: self.superview)
//
//        let minCenter = frame.size.width / 2                            // height도 같은 값
//        let maxCenter = superview.frame.width - frame.size.width / 2    // height도 같은 값
//        let newCenterX = center.x + translation.x
//        let newCenterY = center.y + translation.y
//
//        center.x = min(maxCenter, max(minCenter, newCenterX))
//        center.y = min(maxCenter, max(minCenter, newCenterY))
//        sender.setTranslation(.zero, in: self)
        delegate?.didMoveImagePicker(self, didMoveImagePicker: CGPoint(x: center.x,
                                                                       y: center.y))
    }
    
}
