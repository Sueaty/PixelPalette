//
//  ColorInfoView.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/11/09.
//

import UIKit

final class ColorInfoView: BaseView {
    //MARK:- Views
    private lazy var hexLabel: UILabel = {
        let label = UILabel()
        label.text = "#FFFFFF"
        label.textColor = .init(hexString: "#bfbaba")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var rgbLabel: UILabel = {
        let label = UILabel()
        label.text = "R: 255 / G: 255 / B: 255"
        label.textColor = .init(hexString: "#bfbaba")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var colorInfoStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.isHidden = true
        return stackView
    }()
    
    //MARK:- Properties
    var currentColor: CurrentColor? {
        didSet {
            colorInfoStack.isHidden = false
            
            guard let color = currentColor else { return }
            hexLabel.text = color.hex
            rgbLabel.text = color.rgbText
        }
    }
    
    //MARK:- Override
    override func setViewHierarchy() {
        addSubview(colorInfoStack)
        colorInfoStack.addArrangedSubview(hexLabel)
        colorInfoStack.addArrangedSubview(rgbLabel)
    }
    
    override func setViewConstraint() {
        colorInfoStack.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
        }
    }
    
}

extension ColorInfoView {
    
    func resetInfoViewCondition() {
        colorInfoStack.isHidden = true
    }
    
}
