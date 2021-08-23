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
    var type: ScreenType?
    
    // MARK:- View
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.alpha = 0.3
        imageView.image = UIImage(systemName: "plus.app")
        imageView.image?.withTintColor(.orange)
        return imageView
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        return label
    }()
    
    override func setUI() {
        guard let type = type else { return }
        switch type {
        case .Picker:
            infoLabel.text = "사진을 선택해주세요!"
        case .Library:
            infoLabel.text = "나만의 색을 만들어보세요!"
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
