//
//  UIview+color.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/09/05.
//

import UIKit

extension UIView {
    
    // Core Graphics에서는 화면을 그리기 위해 비트맵 이미지를 활용 (비트맵 이미지 = 픽셀의 집합)
    // CGContext를 활용해서 픽셀 단위로 처리할 수 있음
    func colorOfPoint(point: CGPoint) -> UIColor {
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        var pixelData: [UInt8] = [0, 0, 0, 0]

        let context = CGContext(data: &pixelData,
                                width: 1, height: 1,
                                bitsPerComponent: 8,
                                bytesPerRow: 4,
                                space: colorSpace,
                                bitmapInfo: bitmapInfo.rawValue)
        context!.translateBy(x: -point.x, y: -point.y)

        layer.render(in: context!)

        let red: CGFloat = CGFloat(pixelData[0]) / 255
        let green: CGFloat = CGFloat(pixelData[1]) / 255
        let blue: CGFloat = CGFloat(pixelData[2]) / 255
        let alpha: CGFloat = CGFloat(pixelData[3]) / 255
        let color: UIColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)

        return color
    }
    
}
