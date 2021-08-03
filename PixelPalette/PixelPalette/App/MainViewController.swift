//
//  MainViewController.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/07/28.
//

import UIKit
import SnapKit
import Photos
import AVFoundation

final class MainViewController: BaseViewController {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var pickerView: ColorPickerView = {
        let pickerView = ColorPickerView()
        return pickerView
    }()
    
    private lazy var colorPreview: UIView = {
        let preview = UIView()
        preview.backgroundColor = .yellow
        preview.translatesAutoresizingMaskIntoConstraints = false
        return preview
    }()
    
    private lazy var colorHexLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .blue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var colorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 5
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .green
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var mediaController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mediaController.delegate = self
    }
    
    override func setViewHierarchy() {
        super.setViewHierarchy()
        
        view.addSubview(imageView)
        imageView.addSubview(pickerView)
        imageView.bringSubviewToFront(pickerView)
//        view.addSubview(colorStackView)
//        colorStackView.addArrangedSubview(colorPreview)
//        colorStackView.addArrangedSubview(colorHexLabel)
//        view.addSubview(saveButton)
    }
    
    override func setViewConstraint() {
        super.setViewConstraint()
        
        let commonWidth: CGFloat = view.frame.width * .largeScale
        let calculatedHeight: CGFloat = view.frame.height - 60 // mainHeight - spacings
        
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(commonWidth)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.centerX.equalToSuperview()
        }
        
//        colorPreview.snp.makeConstraints { make in
//            make.width.equalToSuperview().multipliedBy(0.2)
//        }
//
//        colorStackView.snp.makeConstraints { make in
//            make.width.equalTo(commonWidth)
//            make.height.equalTo(calculatedHeight * .smallScale)
//            make.top.equalTo(imageView.snp.bottom).offset(10)
//            make.centerX.equalToSuperview()
//        }
//
//        saveButton.snp.makeConstraints { make in
//            make.width.equalTo(commonWidth)
//            make.height.equalTo(calculatedHeight * .smallScale)
//            make.top.equalTo(colorStackView.snp.bottom).offset(10)
//            make.centerX.equalToSuperview()
//            make.bottom.equalToSuperview().offset(-20)
//        }
    }
    
    override func setUI() {
        let cameraButton = UIBarButtonItem(image: UIImage(systemName: "camera.fill"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapCameraButton(_:)))
        let photosButton = UIBarButtonItem(image: UIImage(systemName: "photo.on.rectangle.angled"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(didTapPhotosButton(_:)))
        navigationItem.rightBarButtonItems = [photosButton, cameraButton]
        navigationItem.title = "Pixel Palette"
    }

}

private extension MainViewController {
    
    @objc func didTapCameraButton(_ sender: UIBarButtonItem) {
        let authState = AVCaptureDevice.authorizationStatus(for: .video)
        if authState == .authorized {
            navigateToUseCamera()
        } else if authState == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
                if granted {
                    self.navigateToUseCamera()
                }
            }
        } else {
            showAlertController(title: "카메라")
        }
    }
    
    @objc func didTapPhotosButton(_ sender: UIBarButtonItem) {
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
            showAlertController(title: "사진첩")
        }
    }
    
    func showAlertController(title: String) {
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
}

extension MainViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func navigateToUseCamera() {
        mediaController.sourceType = .camera
        mediaController.allowsEditing = true
        present(mediaController, animated: true)
    }
    
    func navigateToPhotoLibrary() {
        mediaController.sourceType = .photoLibrary
        mediaController.allowsEditing = true
        present(mediaController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var image: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            image = originalImage
        }
        
        imageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
}
