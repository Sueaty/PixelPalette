//
//  ColorPickerView.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/08/02.
//  Last edit by Sue Cho ono 2021/10/08.
//

import UIKit

protocol ColorPickerDelegate {
    func didTouchColorPicker(_ view: ColorPickerView, at location: CGPoint)
    func didMoveColorPicker(_ view: ColorPickerView, didMoveColorPicker location: CGPoint)
    func didFinishMovingColorPicker(_ view: ColorPickerView, at location: CGPoint)
}

final class ColorPickerView: BaseView {
    
    // MARK:- View
    lazy var colorPicker: UIView = {
        let view = UIView()
        view.layer.borderWidth = 4
        view.layer.cornerRadius = 17
        return view
    }()
    
    // MARK:- Properties
    var color: UIColor?
    var delegate: ColorPickerDelegate?
    
    // MARK:- Override Methods
    override func setInit() {
        isUserInteractionEnabled = true
        isHidden = true
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                          action: #selector(panColorPicker(_:)))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    override func setViewHierarchy() {
        addSubview(colorPicker)
    }
    
    override func setViewConstraint() {
        colorPicker.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    override func setUI() {
        bounds.size = CGSize(width: 34, height: 34)
        resetPickerCondition()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        super.point(inside: point, with: event)
        let touchArea = bounds.insetBy(dx: -50, dy: -50)
        return touchArea.contains(point)
    }
    
    func resetPickerCondition() {
        guard let superview = superview else { return }
        center = CGPoint(x: superview.center.x,
                         y: superview.frame.height / 2)
        colorPicker.backgroundColor = .clear
        colorPicker.layer.borderColor = UIColor.white.cgColor
        isHidden = false
    }
}

private extension ColorPickerView {

    @objc func panColorPicker(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            delegate?.didTouchColorPicker(self, at: CGPoint(x: center.x, y: center.y))
        case .changed:
            setNewCenterPosition(sender)
            setPickerBorderColor()
            delegate?.didMoveColorPicker(self, didMoveColorPicker: CGPoint(x: center.x, y: center.y))
        case .ended:
            delegate?.didFinishMovingColorPicker(self, at: CGPoint(x: center.x, y: center.y))
            colorPicker.backgroundColor = color
            colorPicker.layer.borderColor = UIColor.white.cgColor
        default:
            break
        }
    }

    func setNewCenterPosition(_ sender: UIPanGestureRecognizer) {
        guard let superview = superview else { return }
        let translation = sender.translation(in: self.superview)

        let minCenterX = CGFloat(0)
        let maxCenterX = superview.frame.width - 1
        let newCenterX = center.x + translation.x

        let minCenterY = CGFloat(0)
        let maxCenterY = superview.frame.height - 1
        let newCenterY = center.y + translation.y

        center.x = min(maxCenterX, max(minCenterX, newCenterX))
        center.y = min(maxCenterY, max(minCenterY, newCenterY))

        sender.setTranslation(.zero, in: self)
    }

    func setPickerBorderColor() {
        guard let color = color else { return }
        colorPicker.backgroundColor = .clear
        colorPicker.layer.borderColor = color.cgColor
    }
}
