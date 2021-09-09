//
//  LibraryCell.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/09/09.
//

import UIKit

final class LibraryCell: UICollectionViewCell {
    // MARK:- View
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private lazy var hexLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        return label
    }()
    
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    // MARK:- Properties
    static let identifier = String(describing: LibraryCell.self)
    
    // MARK:- Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setViewHierarchy()
        setViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Update Cycle
    // setNeedsLayout() { setUI() }
    
    func compose(data: Any?) {
        guard let color = data as? PaletteColor else { return }
        contentView.backgroundColor = color.color
        if color.color.isLight {
            hexLabel.backgroundColor = .black
        } else {
            nameLabel.backgroundColor = .white
        }
        
        nameLabel.text = color.name
        hexLabel.text = color.hex
    }
}

private extension LibraryCell {
    
    func setViewHierarchy() {
        contentView.addSubview(labelStackView)
        labelStackView.addArrangedSubview(nameLabel)
        labelStackView.addArrangedSubview(hexLabel)
    }
    
    func setViewConstraints() {
        labelStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
}

//extension RecommendedRestaurantSingleCell {
//
//    func setUI() {
//        let attributedString = NSMutableAttributedString(string: customerReview.text ?? "")
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 5
//        paragraphStyle.lineBreakMode = .byTruncatingTail
//        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
//                                      value: paragraphStyle,
//                                      range: NSMakeRange(0, attributedString.length))
//        customerReview.attributedText = attributedString
//    }
//
