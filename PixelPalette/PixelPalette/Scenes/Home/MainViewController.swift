//
//  MainViewController.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/07/28.
//

import UIKit
import Photos
import SnapKit
import CoreData
import Toast_Swift

final class MainViewController: BaseViewController {
    
    // MARK:- Views
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Picker"
        label.font = UIFont.systemFont(ofSize: 45, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("S A V E".localize(), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.addTarget(self, action: #selector(didTapSaveButton(_:)), for: .touchUpInside)
        button.titleLabel?.textColor = .black
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var imageLoadButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "photo.on.rectangle.angled"), for: .normal)
        button.addTarget(self, action: #selector(didTapPhotosButton(_:)), for: .touchUpInside)
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 1, bottom: 5, right: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var defaultView: DefaultView? = {
        let view = DefaultView(frame: .zero, type: .Picker)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var pickerView: ColorPickerView = {
        let pickerView = ColorPickerView()
        return pickerView
    }()

    private lazy var previewView: ImagePreviewView = {
        let preview = ImagePreviewView()
        let quarterWidth = view.frame.width / 4
        preview.frame = CGRect(x: 0, y: 0,
                               width: quarterWidth, height: quarterWidth)
        return preview
    }()
    
    private lazy var colorInfoView: ColorInfoView = {
        let view = ColorInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK:- Properties
    private lazy var mediaController = UIImagePickerController()
    private lazy var currentColor = CurrentColor(imageView: imageView)
    

    // MARK:- Override Functions
    override func setInit() {
        super.setInit()
        
        mediaController.delegate = self
        pickerView.delegate = self
    }
    
    override func setViewHierarchy() {
        super.setViewHierarchy()
        
        view.addSubview(titleLabel)
        view.addSubview(saveButton)
        view.addSubview(imageLoadButton)
        view.addSubview(defaultView!)
        view.addSubview(imageView)
        imageView.addSubview(pickerView)
        view.addSubview(colorInfoView)
        view.addSubview(previewView)
    }
    
    override func setViewConstraint() {
        super.setViewConstraint()
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }

        imageLoadButton.snp.makeConstraints { make in
            make.height.width.equalTo(45)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.trailing.equalToSuperview().offset(-15)
        }

        saveButton.snp.makeConstraints { make in
            make.height.equalTo(45)
            make.width.equalTo(130)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.trailing.equalTo(imageLoadButton.snp.leading).offset(-15)
        }
        
        defaultView!.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(view.frame.width)
            make.centerY.equalToSuperview().offset(40)
        }
        
        colorInfoView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
    }
    
}

private extension MainViewController {

    @objc func didTapPhotosButton(_ sender: UIButton) {
        let authState = PHPhotoLibrary.authorizationStatus()
        switch authState {
        case .authorized:
            presentPhotoLibrary()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [unowned self] state in
                if state == .authorized {
                    self.presentPhotoLibrary()
                }
            }
        default:
            presentDestructiveAlert(title: "Access to Photos Denied".localize(),
                                    message: "Please go to Settings to allow access to your Photos".localize()) { _ in
                guard let settingURL = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(settingURL, options: [:])
            }
        }
    }
    
    @objc func didTapSaveButton(_ sender: UIButton) {
        guard currentColor.color != nil,
              let hexValue = currentColor.hex else { return }
        
        presentTextFieldAlert(title: hexValue,
                              message: nil,
                              placeholder: "Give a name to your color".localize()) { [unowned self] colorName in
            self.saveColor(name: colorName, hex: hexValue)
        }
    }
    
    func saveColor(name: String, hex: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Color", in: managedContext)!
        let color = NSManagedObject(entity: entity, insertInto: managedContext)
        color.setValue(name, forKey: "name")
        color.setValue(hex, forKey: "hexValue")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            defaultAlertController(title: "Error",
                                   message: "Failed to save due to an error : \(error) \(error.userInfo)")
        }
    }
    
}

extension MainViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defaultView?.removeFromSuperview()
        
        guard let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        imageView.image = editedImage
        
        pickerView.resetPickerCondition()
        colorInfoView.resetInfoViewCondition()
        
        picker.dismiss(animated: true, completion: nil)
    }

    func presentPhotoLibrary() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.mediaController.sourceType = .photoLibrary
            self.mediaController.allowsEditing = true
            self.mediaController.modalPresentationStyle = .fullScreen
            self.present(self.mediaController, animated: true)
        }
    }
    
}

extension MainViewController: ColorPickerDelegate {
    
    func didTouchColorPicker(_ view: ColorPickerView, at location: CGPoint) {
        previewView.isHidden = false
        previewView.previewImage = imageView
        previewView.setTouchPoint(location: location)
    }
    
    func didMoveColorPicker(_ view: ColorPickerView, didMoveColorPicker location: CGPoint) {
        currentColor.location = location
        
        pickerView.color = currentColor.color
        colorInfoView.currentColor = currentColor
        
        saveButton.backgroundColor = currentColor.color
        
        previewView.setTouchPoint(location: location)
        previewView.setNeedsDisplay()
    }
    
    func didFinishMovingColorPicker(_ view: ColorPickerView, at location: CGPoint) {
        previewView.isHidden = true
    }
    
}
