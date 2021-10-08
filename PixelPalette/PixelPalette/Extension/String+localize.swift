//
//  String+localize.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/10/09.
//

import Foundation

extension String {
    func localize(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
}
