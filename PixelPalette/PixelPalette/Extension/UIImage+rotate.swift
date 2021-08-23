//
//  UIImage+rotate.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/08/22.
//

import UIKit

extension UIImage {
    func rotate(by degree: Float) -> UIImage? {
        var newSize = CGRect(origin: .zero,
                             size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(degree))).size
        
        // 매우 작은 소수를 잘라내야 CG가 반올림하지 않음
        let width = floor(newSize.width)
        let height = floor(newSize.height)
        newSize.width = width
        newSize.height = height
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // move origin to middle
        context.translateBy(x: width/2, y: height/2)
        // rotate around middle
        context.rotate(by: CGFloat(degree))
        // draw the image at its center
        self.draw(in: CGRect(x: -width / 2, y: -height / 2, width: width, height: height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
