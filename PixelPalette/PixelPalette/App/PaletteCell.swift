//
//  PaletteCell.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/09/09.
//

import UIKit

final class PaletteCell: UICollectionViewCell {
    // MARK:- Views
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private lazy var hexLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        return label
    }()
    
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 3
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    // MARK:- Properties
    static let identifier = String(describing: PaletteCell.self)
    var colorModel: PaletteColor?
    
    // MARK:- Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 15
        setViewHierarchy()
        setViewConstraints()
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Update Cycle
    func compose(data: Any?) {
        guard let colorModel = data as? PaletteColor else { return }
        self.colorModel = colorModel
        
        let uicolor = UIColor.init(hexString: colorModel.hex)
        self.colorModel?.color = uicolor
        
        nameLabel.text = colorModel.name
        hexLabel.text = colorModel.hex
        
        setUI()
    }
    
    // MARK:- Override
    override func prepareForReuse() {
        nameLabel.attributedText = nil
        hexLabel.attributedText = nil
    }
}

private extension PaletteCell {
    
    func setViewHierarchy() {
        contentView.addSubview(labelStackView)
        labelStackView.addArrangedSubview(nameLabel)
        labelStackView.addArrangedSubview(hexLabel)
    }
    
    func setViewConstraints() {
        labelStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    func setUI() {
        guard let color = colorModel?.color else { return }
        contentView.backgroundColor = color
        
        let whiteHighlight = [NSAttributedString.Key.backgroundColor: UIColor.white]
        let blackHighlight = [NSAttributedString.Key.backgroundColor: UIColor.black]
        if color.isLight {
            let attributedString = NSAttributedString(string: hexLabel.text ?? "",
                                                      attributes: blackHighlight)
            
            hexLabel.attributedText = attributedString
        } else {
            let attributedString = NSAttributedString(string: nameLabel.text ?? "",
                                                      attributes: whiteHighlight)
            nameLabel.attributedText = attributedString
        }
    }
    
}
