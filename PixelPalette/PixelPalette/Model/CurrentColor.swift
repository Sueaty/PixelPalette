//
//  CurrentColor.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/11/09.
//

import UIKit

struct CurrentColor {
    var location: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var imageView: UIImageView
    var color: UIColor? {
        return imageView.colorOfPoint(point: location)
    }
    var hex: String? {
        return color?.toHexString()
    }
}
