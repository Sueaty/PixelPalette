//
//  ColorPickerView.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/08/02.
//  Last edit by Sue Cho ono 2021/10/08.
//

import UIKit

protocol ColorPickerDelegate {
    func didMoveImagePicker(_ view: ColorPickerView, didMoveImagePicker location: CGPoint)
}

final class ColorPickerView: BaseView {
    // MARK:- View
    private var borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.bounds.size = CGSize(width: 40, height: 40)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 20
        return view
    }()
    
    private var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.bounds.size = CGSize(width: 11, height: 11)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()
    
    // MARK:- Properties
    var color: UIColor? {
        didSet {
            guard let color = color else { return }
            if color.isLight {
                borderView.layer.borderColor = UIColor.black.cgColor
                indicatorView.layer.borderColor = UIColor.black.cgColor
            } else {
                borderView.layer.borderColor = UIColor.white.cgColor
                indicatorView.layer.borderColor = UIColor.white.cgColor
            }
        }
    }
    var delegate: ColorPickerDelegate?
    var lastLocation = CGPoint(x: 0, y: 0)
    var imageView: UIImageView = UIImageView()
    
    // MARK:- Override Methods
    override func setInit() {
        bounds.size = CGSize(width: 40, height: 40)
        isUserInteractionEnabled = true
        isHidden = true
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                          action: #selector(panColorPicker(_:)))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    override func setViewHierarchy() {
        addSubview(borderView)
        addSubview(indicatorView)
    }
    
    override func setViewConstraint() {
        borderView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        indicatorView.snp.makeConstraints { make in
            make.width.height.equalTo(11)
            make.center.equalToSuperview()
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        super.point(inside: point, with: event)
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
//        if sender.state == .began || sender.state == .changed {
//            bounds.size = CGSize(width: 26, height: 26)
//            layer.cornerRadius = 13
//        } else if sender.state == .ended {
//            bounds.size = CGSize(width: 20, height: 20)
//            layer.cornerRadius = 10
//        }
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
