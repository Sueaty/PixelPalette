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
    var rgba: [Int]? {
        return color?.toRGBA()
    }
    var rgbText: String? {
        guard let rgba = rgba else { return "" }
        return "R : \(rgba[0]) / G : \(rgba[1]) / B : \(rgba[2])"
    }
}
