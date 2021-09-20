//
//  SingleColorViewController.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/09/18.
//

import UIKit
import SnapKit
import CoreData

protocol SingleColorDelegate {
    func didEditColorName(_ viewController: SingleColorViewController, didEditName to: String)
    func didDeleteColor(_ viewController: SingleColorViewController, deletedColor name: String)
}

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
        button.backgroundColor = .lightGray.withAlphaComponent(0.9)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK:- Properties
    var delegate: SingleColorDelegate?
    var colorModel: PaletteColor?
    var backgroundTopConstraint: Constraint?
    var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func compose(data: Any?) {
        guard let colorModel = data as? PaletteColor,
              let color = colorModel.color else { return }
       
        self.colorModel = colorModel
        
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
    
    @objc func didPressSaveButton(_ sender: UIButton) {
        guard let colorModel = colorModel,
              let textFieldString = nameLabelTextField.text else { return }
        let nameDidChange = colorModel.name != textFieldString
        
        if nameDidChange {
            updateColorName(change: textFieldString)
            delegate?.didEditColorName(self, didEditName: textFieldString)
        }

        dismiss(animated: true, completion: nil)
    }
    
    @objc func didPressDeleteButton(_ sender: UIButton) {
        // delete from core data
        let alert = UIAlertController(title: "색상 삭제",
                                      message: "\(colorModel!.name) 색을 지우시겠습니까?",
                                      preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            let fetchColor: NSFetchRequest<Color> = Color.fetchRequest()
            fetchColor.predicate = NSPredicate(format: "name = %@", self.colorModel!.name as String)
            let result = try? self.context.fetch(fetchColor)
            let color: Color! = result?.first
            self.context.delete(color)
            
            do {
                try self.context.save()
            } catch {
                print("Failed to delete: \(error)")
            }
            
            self.delegate?.didDeleteColor(self, deletedColor: self.colorModel!.name)
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(cancel)
        alert.addAction(delete)
        present(alert, animated: true, completion: nil)
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
    
    func updateColorName(change name: String) {
        let fetchColor: NSFetchRequest<Color> = Color.fetchRequest()
        fetchColor.predicate = NSPredicate(format: "name = %@", colorModel!.name as String)
        
        let result = try? context.fetch(fetchColor)
        let color: Color! = result?.first
        
        color.name = name
        do {
            try context.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }

}
