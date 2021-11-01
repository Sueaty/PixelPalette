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
import AudioToolbox

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
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var pickerView: ColorPickerView = {
        let pickerView = ColorPickerView()
        return pickerView
    }()
    
    // MARK:- Properties
    private var widthConstraint: Constraint?
    private lazy var mediaController = UIImagePickerController()
    private var image: UIImage? {
        didSet {
            resetPickerCondition()
        }
    }
    private var pickedColor: UIColor? {
        didSet {
            pickerView.color = pickedColor
        }
    }

    // MARK:- Override Functions
    override func setInit() {
        super.setInit()
        
        mediaController.delegate = self
        pickerView.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(tappedImageView(_:)))
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func setViewHierarchy() {
        super.setViewHierarchy()
        
        view.addSubview(titleLabel)
        view.addSubview(saveButton)
        view.addSubview(imageLoadButton)
        view.addSubview(defaultView!)
        view.addSubview(imageView)
        imageView.addSubview(pickerView)    }
    
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
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(90)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(view.frame.width)
        }
    }
    
}

private extension MainViewController {
    
    // When user taps on image to change picker view's position
    @objc func tappedImageView(_ sender: UITapGestureRecognizer) {
        let tappedLocation = sender.location(in: sender.view)
        pickerView.center = tappedLocation
    }
    
    // When 'photos' button is tapped,
    @objc func didTapPhotosButton(_ sender: UIButton) {
        /// check for authorization status
        let authState = PHPhotoLibrary.authorizationStatus()
        
        /// Case #1 : Authorized
        if authState == .authorized {
            /// open photos library
            presentPhotoLibrary()
        }
        /// Case #2 : Not Determined
        else if authState == .notDetermined {
            /// request for authorization
            PHPhotoLibrary.requestAuthorization { [unowned self] state in
                /// if user authorizes, then open photos library
                if state == .authorized {
                    self.presentPhotoLibrary()
                }
            }
        }
        /// Case #3 : No Authorization
        else {
            /// ask user to authorize app in the Settings
            showAccessAuthAlert()
        }
    }
    
    // When 'save' button is tapped
    @objc func didTapSaveButton(_ sender: UIButton) {
        /// If picker view has picked a color, ask user if he/she wants to save the color
        if pickedColor != nil { showSaveAlert() }
    }
    
    // Reset Picker when new image is loaded
    func resetPickerCondition() {
        /// set picker's position to center
        let centerPoint = CGPoint(x: imageView.center.x,
                                  y: imageView.frame.size.height / 2)
        pickerView.lastLocation = centerPoint
        pickerView.center = centerPoint
        
        /// reveal picker view
        pickerView.isHidden = false
    }
    
    // Alert to navigate user to Setting for Photos Library authorization
    func showAccessAuthAlert() {
        let alert = UIAlertController(title: "Access to Photos Denied".localize(),
                                      message: "Please go to Settings to allow access to your Photos".localize(),
                                      preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel".localize(), style: .cancel, handler: nil)
        let confirm = UIAlertAction(title: "Settings".localize(), style: .default, handler: { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                      options: [:],
                                      completionHandler: nil)
        })
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        present(alert, animated: false, completion: nil)
    }
    
    // Alert to save color
    func showSaveAlert() {
        guard let colorHexValue = pickedColor?.toHexString().uppercased() else { return }
        let alert = UIAlertController(title: colorHexValue, message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel".localize(), style: .cancel)
        let save = UIAlertAction(title: "Save".localize(), style: .default) { [weak self] action in
            guard let self = self,
                  let colorName = alert.textFields?[0].text else { return }
            
            if colorName.isEmpty {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                self.view.makeToast("Give a Name to Save the Color".localize())
            } else {
                // save color to core data
                self.saveColor(name: colorName, hex: colorHexValue)
                self.view.makeToast("Color Saved".localize())
            }
        }
        
        alert.addAction(save)
        alert.addAction(cancel)
    
        alert.addTextField { textField in
            textField.placeholder = "Give a name to your color".localize()
        }
        present(alert, animated: false, completion: nil)
    }
    
    // Save color in CoreData
    func saveColor(name: String, hex: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Color",
                                                in: managedContext)!
        let color = NSManagedObject(entity: entity,
                                    insertInto: managedContext)
        color.setValue(name, forKey: "name")
        color.setValue(hex, forKey: "hexValue")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Failed to save : \(error) \(error.userInfo)")
        }
    }
    
}

extension MainViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defaultView?.removeFromSuperview()
        
        guard let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        image = editedImage
        imageView.image = image
        
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
    
    func didMoveImagePicker(_ view: ColorPickerView, didMoveImagePicker location: CGPoint) {
        pickedColor = imageView.colorOfPoint(point: location)
        saveButton.backgroundColor = pickedColor
        saveButton.titleLabel!.textColor = pickedColor!.isLight ? .black : .white
    }

}
