//
//  DefaultView.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/08/23.
//

import UIKit
import SnapKit

enum ScreenType {
    case Picker
    case Library
}

final class DefaultView: BaseView {
    // MARK:- Properties
    var type: ScreenType
    
    // MARK:- View
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.alpha = 0.3
        imageView.image = UIImage(systemName: "paintbrush.fill")
        imageView.tintColor = UIColor.init(hexString: "#fdf1bd")
        return imageView
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        return label
    }()
    
    // MARK:- Initializer
    init(frame: CGRect, type: ScreenType) {
        self.type = type
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Function Override
    override func setUI() {
        switch type {
        case .Picker:
            infoLabel.text = "Choose Your Photo".localize()
        case .Library:
            infoLabel.text = "Create Your Own Color".localize()
        }
    }
    
    override func setViewHierarchy() {
        addSubview(imageView)
        addSubview(infoLabel)
    }
    
    override func setViewConstraint() {
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.center.equalToSuperview()
        }
        
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
    }
}
