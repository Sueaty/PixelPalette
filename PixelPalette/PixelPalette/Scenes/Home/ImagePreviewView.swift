//
//  ImagePreviewView.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/11/10.
//

import UIKit

final class ImagePreviewView: BaseView {
    //MARK:- Views
    private lazy var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK:- Properties
    var previewImage: UIImageView!
    var location: CGPoint?
    
    //MARK:- Override Methods
    override func setInit() {
        isHidden = true
        layer.masksToBounds = true
    }
    
    override func setUI() {
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
    }
    
    override func setViewHierarchy() {
        addSubview(indicatorView)
    }
    
    override func setViewConstraint() {
        indicatorView.snp.makeConstraints { make in
            make.width.height.equalTo(15)
            make.center.equalToSuperview()
        }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(),
              let location = location else { return }
        context.translateBy(x: 1 * frame.width * 0.5,
                            y: 1 * frame.height * 0.5)
        context.scaleBy(x: 2.5, y: 2.5)
        context.translateBy(x: -1 * location.x,
                            y: -1 * location.y)
        previewImage.layer.render(in: context)
    }
    
    func setTouchPoint(location: CGPoint) {
        self.location = location
        
        guard let superview = superview else { return }
        let minCenterX = frame.width / 2
        let maxCenterX = superview.frame.width - frame.width / 2
        let newCenterX = location.x
        
        center.x = min(maxCenterX, max(minCenterX, newCenterX))
        center.y = location.y + 180
    }

}
