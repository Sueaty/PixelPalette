//
//  TitleView.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/09/09.
//

import UIKit

final class TitleHeaderView: UICollectionReusableView {
    
    //MARK:- View
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Palette"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 45, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK:- Properties
    static let identifier = String(describing: TitleHeaderView.self)

    //MARK:- Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setViewHierarchy()
        setViewConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension TitleHeaderView {
    
    func setViewHierarchy() {
        addSubview(titleLabel)
    }
    
    func setViewConstraint() {
        titleLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
    }
    
}
