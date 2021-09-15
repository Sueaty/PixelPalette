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
        scrollView.showsHorizontalScrollIndicator = false
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
    private var imageViewWidthConstraint: Constraint?
    private lazy var mediaController = UIImagePickerController()
    private var image: UIImage? {
        didSet {
            let centerX = view.frame.width / 2
            let centerY = (UIScreen.main.bounds.height - tabbarHeight) / 2
            let centerPoint = CGPoint(x: centerX, y: centerY)
            pickerView.lastLocation = centerPoint
            pickerView.center = centerPoint
            pickerView.isHidden = false
            pickedColor = nil
            pickerView.imageView = imageView

            let viewHeight = imageScrollView.frame.height
            let imageHeight = image!.size.height
            let imageWidth = image!.size.width
            let increaseRatio = viewHeight / imageHeight
            
            imageView.snp.makeConstraints { make in
                make.width.equalTo(imageWidth * increaseRatio)
                    .priority(999)
            }
        }
    }
    private var pickedColor: UIColor?
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
    
    override func setUI() {
        super.setUI()
        
    }
    
}

private extension MainViewController {

    @objc func didTapPhotosButton(_ sender: UIButton) {
        let authState = PHPhotoLibrary.authorizationStatus()
        if authState == .authorized {
            DispatchQueue.main.async {
                self.navigateToPhotoLibrary()
            }
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
                  let colorName = alert.textFields?[0].text else {
                // 이거 진짜 진동 되는것인가...?
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
                return
            }
            
            // save color to core data
            self.saveColor(name: colorName, hex: colorHexValue!)
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
        mediaController.sourceType = .photoLibrary
        mediaController.allowsEditing = false
        present(mediaController, animated: true)
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
        pickerView.layer.borderColor = pickedColor!.isLight ? UIColor.black.cgColor : UIColor.white.cgColor
        saveButton.backgroundColor = pickedColor
        saveButton.titleLabel!.textColor = pickedColor!.isLight ? .black : .white
    }

}
