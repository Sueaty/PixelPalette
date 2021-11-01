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
    var color: UIColor?
    var delegate: ColorPickerDelegate?
    var lastLocation = CGPoint(x: 0, y: 0)
    
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
        setNewCenterPosition(sender)
        delegate?.didMoveImagePicker(self, didMoveImagePicker: CGPoint(x: center.x, y: center.y))
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

}
