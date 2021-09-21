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
    var imageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panColorPicker(_:)))
        addGestureRecognizer(panGestureRecognizer)
        
        bounds.size = CGSize(width: 20, height: 20)
        
        layer.borderWidth = 4
        layer.cornerRadius = 10
        layer.isOpaque = false
        layer.borderColor = UIColor.black.cgColor
        layer.backgroundColor = UIColor.clear.cgColor
        
        isHidden = true
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        super.point(inside: point, with: event)
        
        // add extra 50 touch area (negative value increases the touchable area)
        let touchArea = bounds.insetBy(dx: -50, dy: -50)
        return touchArea.contains(point)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastLocation = self.center
    }
}

private extension ColorPickerView {
    
    @objc func panColorPicker(_ sender: UIPanGestureRecognizer) {
        adjustPickerViewSize(sender)
        setNewCenterPosition(sender)
        delegate?.didMoveImagePicker(self, didMoveImagePicker: CGPoint(x: center.x, y: center.y))
    }
    
    func adjustPickerViewSize(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            bounds.size = CGSize(width: 26, height: 26)
            layer.cornerRadius = 13
        } else if sender.state == .ended {
            bounds.size = CGSize(width: 20, height: 20)
            layer.cornerRadius = 10
        }
    }
    
    func setNewCenterPosition(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.superview)
        
        let minCenterX = frame.size.width / 2
        let maxCenterX = imageView.frame.width - frame.size.width / 2
        let newCenterX = center.x + translation.x

        let minCenterY = imageView.frame.origin.y
        let maxCenterY = minCenterY + imageView.frame.size.height
        let newCenterY = center.y + translation.y

        center.x = min(maxCenterX, max(minCenterX, newCenterX))
        center.y = min(maxCenterY, max(minCenterY, newCenterY))

        sender.setTranslation(.zero, in: self)
    }
    
}
