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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("S A V E", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.addTarget(self, action: #selector(savePickedColor(_:)), for: .touchUpInside)
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
    
    private lazy var imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(origin: .zero,
                                  size: view.frame.size)
        scrollView.contentSize = imageView.frame.size
        scrollView.bounces = false
        scrollView.clipsToBounds = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
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
            scrollToBeginning()
            resetImageViewConstraint()
            resetPicker()
        }
    }
    private var pickedColor: UIColor? {
        didSet {
            pickerView.layer.borderColor = pickedColor!.isLight ? UIColor.black.cgColor : UIColor.white.cgColor
        }
    }
    private var statusBarHeight: CGFloat {
        return view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }
    private var tabbarHeight: CGFloat {
        return tabBarController!.tabBar.frame.height
    }

    // MARK:- Override Functions
    override func setInit() {
        super.setInit()
        
        mediaController.delegate = self
        imageScrollView.delegate = self
        pickerView.delegate = self
    }
    
    override func setViewHierarchy() {
        super.setViewHierarchy()
        
        view.addSubview(titleLabel)
        view.addSubview(saveButton)
        view.addSubview(imageLoadButton)
        view.addSubview(defaultView!)
        view.addSubview(imageScrollView)
        imageScrollView.addSubview(imageView)
        imageScrollView.addSubview(pickerView)
        imageScrollView.bringSubviewToFront(pickerView)
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

        imageScrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(90)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(imageScrollView.contentLayoutGuide.snp.top)
            make.bottom.equalTo(imageScrollView.contentLayoutGuide.snp.bottom)
            make.leading.equalTo(imageScrollView.contentLayoutGuide.snp.leading)
            make.trailing.equalTo(imageScrollView.contentLayoutGuide.snp.trailing)
            
            make.height.equalTo(imageScrollView.frameLayoutGuide.snp.height)
        }
    }

}

private extension MainViewController {

    @objc func didTapPhotosButton(_ sender: UIButton) {
        let authState = PHPhotoLibrary.authorizationStatus()
        if authState == .authorized {
            self.navigateToPhotoLibrary()
        } else if authState == .notDetermined {
            PHPhotoLibrary.requestAuthorization { [unowned self] state in
                if state == .authorized {
                    self.navigateToPhotoLibrary()
                }
            }
        } else {
            showAccessAuthAlert(title: "사진첩")
        }
    }
    
    @objc func savePickedColor(_ sender: UIButton) {
        if pickedColor != nil { showSaveAlert() }
    }
    
    func scrollToBeginning() {
        let leftContentOffset = CGPoint(x: -imageScrollView.contentInset.left, y: 0)
        imageScrollView.setContentOffset(leftContentOffset, animated: true)
    }
    
    func resetPicker() {
        // set picker position
        let centerPoint = CGPoint(x: imageScrollView.center.x,
                                  y: imageScrollView.frame.size.height / 2)
        pickerView.lastLocation = centerPoint
        pickerView.center = centerPoint
        pickerView.isHidden = false
        pickerView.imageView = imageView
        
        // set picker's initial position color
        pickedColor = imageView.colorOfPoint(point: centerPoint)
    }
    
    func resetImageViewConstraint() {
        widthConstraint?.deactivate()
        
        let viewHeight = imageScrollView.frame.height
        let imageHeight = image!.size.height
        let imageWidth = image!.size.width
        let increaseRatio = viewHeight / imageHeight
        imageView.snp.makeConstraints { make in
            widthConstraint = make.width.equalTo(imageWidth * increaseRatio).priority(999).constraint
        }
        
        widthConstraint?.activate()
    }
    
    func showAccessAuthAlert(title: String) {
        let alert = UIAlertController(title: "\(title)에 대한 접근 권한이 없어요.",
                                      message: "설정 앱에서 권한을 수정해주세요 :)",
                                      preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let confirm = UIAlertAction(title: "지금 설정하기", style: .default, handler: { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                      options: [:],
                                      completionHandler: nil)
        })
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        present(alert, animated: false, completion: nil)
    }
    
    func showSaveAlert() {
        let colorHexValue = pickedColor?.toHexString().uppercased()
        let alert = UIAlertController(title: colorHexValue ?? "색 지정",
                                      message: nil,
                                      preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let save = UIAlertAction(title: "저장", style: .default) { [weak self] action in
            guard let self = self,
                  let colorName = alert.textFields?[0].text else { return }
            
            if colorName.isEmpty {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                self.view.makeToast("이름이 없어 저장할 수 없었어요ㅠ.ㅠ")
            } else {
                // save color to core data
                self.saveColor(name: colorName, hex: colorHexValue!)
                self.view.makeToast("Successfullly Saved Color")
            }
        }
        
        alert.addAction(save)
        alert.addAction(cancel)
    
        alert.addTextField { textField in
            textField.placeholder = "당신의 색 이름을 정해주세요"
        }
        present(alert, animated: false, completion: nil)
    }
    
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
    
    func navigateToPhotoLibrary() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.mediaController.sourceType = .photoLibrary
            self.mediaController.allowsEditing = false
            self.present(self.mediaController, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defaultView?.removeFromSuperview()
        
        guard let originalImage = info[.originalImage] as? UIImage else { return }
        image = originalImage
        imageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension MainViewController: UIScrollViewDelegate {
    
}

extension MainViewController: ColorPickerDelegate {
    
    func didMoveImagePicker(_ view: ColorPickerView, didMoveImagePicker location: CGPoint) {
        pickedColor = imageView.colorOfPoint(point: location)
        saveButton.backgroundColor = pickedColor
        saveButton.titleLabel!.textColor = pickedColor!.isLight ? .black : .white
    }

}
