//
//  SingleColorViewController.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/09/18.
//

import UIKit
import SnapKit

final class SingleColorViewController: BaseViewController {
    
    // MARK:- Views
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var decorationView: UIView = {
        let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0),
                                        size: CGSize(width: view.frame.width - 38, height: 150)))
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var colorInfoStackView: UIStackView = {
        let stackview = UIStackView()
        stackview.axis = .vertical
        stackview.distribution = .equalSpacing
        stackview.spacing = 1
        stackview.translatesAutoresizingMaskIntoConstraints = false
        return stackview
    }()
    
    private lazy var nameLabelTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        textField.textColor = .black
        return textField
    }()
    
    private lazy var hexStringLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private lazy var rgbaLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(didPressSaveButton(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(didPressDeleteButton(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK:- Override Functions
    override func setViewHierarchy() {
        super.setViewHierarchy()
        
        view.addSubview(backgroundView)
        backgroundView.addSubview(decorationView)
        backgroundView.addSubview(colorInfoStackView)
        colorInfoStackView.addArrangedSubview(nameLabelTextField)
        colorInfoStackView.addArrangedSubview(hexStringLabel)
        colorInfoStackView.addArrangedSubview(rgbaLabel)
        backgroundView.addSubview(saveButton)
        view.addSubview(deleteButton)
    }
    
    override func setViewConstraint() {
        super.setViewConstraint()
        
        let widthLength: CGFloat = view.frame.size.width * 0.75
        
        backgroundView.snp.makeConstraints { make in
            make.width.height.equalTo(widthLength)
            make.centerX.equalToSuperview()
            backgroundTopConstraint = make.centerY.equalToSuperview().constraint
            backgroundTopConstraint?.activate()
        }
        
        decorationView.snp.makeConstraints { make in
            make.width.equalTo(widthLength)
            make.height.equalTo(120)
            make.leading.equalToSuperview().offset(view.frame.size.width * 0.07)
            make.bottom.equalToSuperview().offset(-45)
        }
        
        colorInfoStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(backgroundView.snp.bottom).offset(15)
            make.width.equalTo(widthLength)
            make.height.equalTo(40)
        }
    }
    
    override func setUI() {
        super.setUI()
        
        view.backgroundColor = .white.withAlphaComponent(0.5)
        view.isOpaque = true
    }
    
    // MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObservers()
    }
    
    // MARK:- Properties
    var color: PaletteColor?
    var backgroundTopConstraint: Constraint?
    
    func compose(data: Any?) {
        guard let colorModel = data as? PaletteColor,
              let color = colorModel.color else { return }
        
        if color.isLight {
            saveButton.setTitleColor(.black, for: .normal)
            saveButton.titleLabel?.textColor = .black
        } else {
            saveButton.setTitleColor(.white, for: .normal)
            saveButton.titleLabel?.textColor = .white
        }
        
        backgroundView.backgroundColor = color
        nameLabelTextField.text = colorModel.name
        hexStringLabel.text = colorModel.hex
        let rgba = color.toRGBA()
        rgbaLabel.text = String(describing: "(\(rgba[0]), \(rgba[1]), \(rgba[2]))")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

private extension SingleColorViewController {
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func didPressSaveButton(_ sender: UIButton) {
        // no change was made
        
        // name edited
    }
    
    @objc func didPressDeleteButton(_ sender: UIButton) {
        // delete from core data
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        backgroundTopConstraint?.deactivate()
        backgroundView.snp.makeConstraints { make in
            backgroundTopConstraint = make.top.equalToSuperview().offset(10).constraint
        }
        backgroundTopConstraint?.activate()
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        backgroundTopConstraint?.deactivate()
        backgroundView.snp.makeConstraints { make in
            backgroundTopConstraint = make.centerY.equalToSuperview().constraint
        }
        backgroundTopConstraint?.activate()
    }
}
