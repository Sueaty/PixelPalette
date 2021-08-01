//
//  MainViewController.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/07/28.
//

import UIKit
import SnapKit
import AVFoundation

final class MainViewController: BaseViewController {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
        view.addSubview(colorStackView)
        colorStackView.addArrangedSubview(colorPreview)
        colorStackView.addArrangedSubview(colorHexLabel)
        view.addSubview(saveButton)
    }
    
    override func setViewConstraint() {
        super.setViewConstraint()
        
        let commonWidth: CGFloat = view.frame.width * .largeScale
        let calculatedHeight: CGFloat = view.frame.height - 60 // mainHeight - spacings
        
        imageView.snp.makeConstraints { make in
            make.width.equalTo(commonWidth)
            make.height.equalTo(calculatedHeight * 0.7)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalToSuperview()
        }
        
        colorPreview.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.2)
        }
                
        colorStackView.snp.makeConstraints { make in
            make.width.equalTo(commonWidth)
            make.height.equalTo(calculatedHeight * .smallScale)
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        saveButton.snp.makeConstraints { make in
            make.width.equalTo(commonWidth)
            make.height.equalTo(calculatedHeight * .smallScale)
            make.top.equalTo(colorStackView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        }
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
    }

}

private extension MainViewController {
    @objc func didTapCameraButton(_ sender: UIBarButtonItem) {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
            if granted {
                print("Camera: 권한 허용")
            } else {
                print("Camera: 권한 거부")
            }
        })
    }
    
    @objc func didTapPhotosButton(_ sender: UIBarButtonItem) {
//        PHPhotoLibrary.requestAuthorization( { status in
//            switch status{
//            case .authorized:
//                print("Gallery: 권한 허용")
//            case .denied:
//                print("Gallery: 권한 거부")
//            case .restricted, .notDetermined:
//                print("Gallery: 선택하지 않음")
//            default:
//                break
//            }
//        })
    }
}

extension MainViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func navigateToUseCameraApp() {
        mediaController.sourceType = .camera
        mediaController.allowsEditing = true
        navigationController?.present(mediaController, animated: true, completion: nil)
//        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        // print out the image size as a test
        print(image.size)
    }
}
