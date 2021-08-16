//
//  UIImage+getColor.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/08/16.
//

import UIKit

extension UIImage {
    
    func getPixelColor(point: CGPoint) -> UIColor? {
        guard let cgImage = cgImage,
            let pixelData = cgImage.dataProvider?.data
            else { return nil }

        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        let alphaInfo = cgImage.alphaInfo
        assert(alphaInfo == .premultipliedFirst || alphaInfo == .first || alphaInfo == .noneSkipFirst, "This routine expects alpha to be first component")

        let byteOrderInfo = cgImage.byteOrderInfo
        assert(byteOrderInfo == .order32Little || byteOrderInfo == .orderDefault, "This routine expects little-endian 32bit format")

        let bytesPerRow = cgImage.bytesPerRow
        let pixelInfo = Int(point.y) * bytesPerRow + Int(point.x) * 4;

        let a: CGFloat = CGFloat(data[pixelInfo+3]) / 255
        let r: CGFloat = CGFloat(data[pixelInfo+2]) / 255
        let g: CGFloat = CGFloat(data[pixelInfo+1]) / 255
        let b: CGFloat = CGFloat(data[pixelInfo  ]) / 255

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
