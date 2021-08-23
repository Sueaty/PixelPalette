//
//  UIImage+getColor.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/08/16.
//

import UIKit

//extension UIImage {
//
//    subscript (location: CGPoint) -> UIColor? {
//        let x = location.x
//        let y = location.y
//
//        let provider = self.cgImage!.dataProvider
//        let providerData = provider!.data
//        let data = CFDataGetBytePtr(providerData)
//
//        let numberOfComponents = 4
//        let pixelData = ((Int(size.width) * y) + x) * numberOfComponents
//
//        let r = CGFloat(data![pixelData]) / 255.0
//        let g = CGFloat(data![pixelData + 1]) / 255.0
//        let b = CGFloat(data![pixelData + 2]) / 255.0
//        let a = CGFloat(data![pixelData + 3]) / 255.0
//
//        return UIColor(red: r, green: g, blue: b, alpha: a)
//    }
//}
