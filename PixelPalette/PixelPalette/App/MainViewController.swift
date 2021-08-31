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

class PixelExtractor: NSObject {

    let image: CGImage
    let context: CGContext?

    var width: Int {
        get {
            return image.width
        }
    }

    var height: Int {
        get {
            return image.height
        }
    }


    init(img: CGImage) {
        image = img
        context = PixelExtractor.createBitmapContext(img: img)
    }

    class func createBitmapContext(img: CGImage) -> CGContext {

        // Get image width, height
        let pixelsWide = img.width
        let pixelsHigh = img.height

        let bitmapBytesPerRow = pixelsWide * 4
        let bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)

        // Use the generic RGB color space.
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        // Allocate memory for image data. This is the destination in memory
        // where any drawing to the bitmap context will be rendered.
        let bitmapData = malloc(bitmapByteCount)
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let size = CGSize(width: CGFloat(pixelsWide), height: CGFloat(pixelsHigh))
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        // create bitmap
        let context = CGContext(data: bitmapData,
                                width: pixelsWide,
                                height: pixelsHigh,
                                bitsPerComponent: 8,
                                bytesPerRow: bitmapBytesPerRow,
                                space: colorSpace,
                                bitmapInfo: bitmapInfo.rawValue)

        // draw the image onto the context
        let rect = CGRect(x: 0, y: 0, width: pixelsWide, height: pixelsHigh)

        context?.draw(img, in: rect)

        return context!
    }

    func colorAt(x: CGFloat, y: CGFloat) -> UIColor {

        guard let pixelBuffer = context?.data else { return .white }
        let data = pixelBuffer.bindMemory(to: UInt8.self, capacity: width * height)

        let offset: Int = Int(4 * (y * CGFloat(width) + x))

        let alpha: UInt8 = data[offset]
        let red: UInt8 = data[offset+1]
        let green: UInt8 = data[offset+2]
        let blue: UInt8 = data[offset+3]

        
        let color = UIColor(red: CGFloat(red)/255.0,
                            green: CGFloat(green)/255.0,
                            blue: CGFloat(blue)/255.0,
                            alpha: CGFloat(alpha)/255.0)

        return color
    }
}

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
    
    private var extractor: PixelExtractor?
    private var pixelData: CFData?
    private var data: UnsafePointer<UInt8>?
    private var image: UIImage? {
        didSet {
            let centerX = view.frame.width / 2
            let centerY = (UIScreen.main.bounds.height - navigationBarHeight - tabbarHeight) / 2
            print(centerY)
            let centerPoint = CGPoint(x: centerX, y: centerY)
            pickerView.lastLocation = centerPoint
            pickerView.center = centerPoint
            
            pickerView.isHidden = false
            pickedColor = nil
            extractor = PixelExtractor(img: (image?.cgImage)!)
            
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
        // TO DO: 색 hex 값으로 제목 지정
        let alert = UIAlertController(title: "색 저장",
                                      message: "text field",
                                      preferredStyle: .alert)
        let save = UIAlertAction(title: "저장", style: .default) { action in
            let colorName = alert.textFields?[0].text
            // save color
        }
        
        alert.addAction(save)
        alert.addTextField { textField in
            textField.placeholder = "당신의 색 이름을 정해주세요"
        }
        present(alert, animated: false, completion: nil)
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
        let x = location.x
        let y = location.y
        pickedColor = extractor?.colorAt(x: x, y: y)
        navigationItem.leftBarButtonItem?.tintColor = pickedColor
        
    }

}
