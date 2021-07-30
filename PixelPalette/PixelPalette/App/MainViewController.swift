//
//  MainViewController.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/07/28.
//

import UIKit
import SnapKit

final class MainViewController: BaseViewController {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var colorPreview: UIView = {
        let preview = UIView()
        preview.backgroundColor = .yellow
        preview.translatesAutoresizingMaskIntoConstraints = false
        return preview
    }()
    
    private lazy var colorHexLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .blue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var colorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 5
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .green
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setViewHierarchy() {
        super.setViewHierarchy()
        
        view.addSubview(imageView)
        view.addSubview(colorStackView)
        colorStackView.addArrangedSubview(colorPreview)
        colorStackView.addArrangedSubview(colorHexLabel)
        view.addSubview(saveButton)
    }
    
    override func setViewConstraint() {
        super.setViewConstraint()
        
        let commonWidth: CGFloat = view.frame.width * .largeScale
        let calculatedHeight: CGFloat = view.frame.height - 60 // mainHeight - spacings
        
        imageView.snp.makeConstraints { make in
            make.width.equalTo(commonWidth)
            make.height.equalTo(calculatedHeight * 0.7)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalToSuperview()
        }
        
        colorStackView.snp.makeConstraints { make in
            make.width.equalTo(commonWidth)
            make.height.equalTo(calculatedHeight * .smallScale)
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        saveButton.snp.makeConstraints { make in
            make.width.equalTo(commonWidth)
            make.height.equalTo(calculatedHeight * .smallScale)
            make.top.equalTo(colorStackView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
    }

}

extension CGFloat {
    static let largeScale: CGFloat = 0.9
    static let smallScale: CGFloat = 0.1
}

