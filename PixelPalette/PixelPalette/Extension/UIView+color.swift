//
//  UIview+color.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/09/05.
//

import UIKit

extension UIView {
    
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
