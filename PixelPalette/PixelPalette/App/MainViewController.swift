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
    
    private lazy var defaultView: DefaultView = {
        let view = DefaultView(frame: .zero, type: .Picker)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var pickerView: ColorPickerView = {
        let pickerView = ColorPickerView()
        return pickerView
    }()

    private lazy var mediaController = UIImagePickerController()
    
    private var pixelData: CFData?
    private var data: UnsafePointer<UInt8>?
    private var image: UIImage? {
        didSet {
            let centerX = view.frame.width / 2
            let centerY = (UIScreen.main.bounds.height - navigationBarHeight - tabbarHeight) / 2
            let centerPoint = CGPoint(x: centerX, y: centerY)
            pickerView.lastLocation = centerPoint
            pickerView.center = centerPoint
            pickerView.isHidden = false
            pickedColor = nil
            pickerView.imageView = imageView
        }
    }
    
    private var pickedColor: UIColor?
    private var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    private var navigationBarHeight: CGFloat {
        return navigationController!.navigationBar.intrinsicContentSize.height
    }
    private var tabbarHeight: CGFloat {
        return tabBarController!.tabBar.frame.height
    }

    override func setInit() {
        mediaController.delegate = self
        pickerView.delegate = self
    }
    
    override func setViewHierarchy() {
        super.setViewHierarchy()
        view.addSubview(defaultView)
        view.addSubview(imageView)
        imageView.addSubview(pickerView)
        imageView.bringSubviewToFront(pickerView)
    }
    
    override func setViewConstraint() {
        super.setViewConstraint()
        
        defaultView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    override func setUI() {
        super.setUI()
        
        let colorPreview = UIBarButtonItem(image: UIImage(systemName: "square.fill"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(savePickedColor(_:)))
        colorPreview.tintColor = .lightGray
        
        let photosButton = UIBarButtonItem(image: UIImage(systemName: "photo.on.rectangle.angled"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(didTapPhotosButton(_:)))
        
        navigationItem.leftBarButtonItem = colorPreview
        navigationItem.rightBarButtonItem = photosButton
        navigationItem.title = "Pixel Palette"
    }

}

private extension MainViewController {
    
    @objc func didTapPhotosButton(_ sender: UIBarButtonItem) {
        // view
        if image == nil {
            defaultView.removeFromSuperview()
        }
        
        // authorize
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
    
    @objc func savePickedColor(_ sender: UIBarButtonItem) {
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
        guard let originalImage = info[.originalImage] as? UIImage else { return }
        
        image = originalImage
        imageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension MainViewController: ColorPickerDelegate {
    
    func didMoveImagePicker(_ view: ColorPickerView, didMoveImagePicker location: CGPoint) {
        pickedColor = imageView.colorOfPoint(point: location)
        navigationItem.leftBarButtonItem?.tintColor = pickedColor
    }

}
