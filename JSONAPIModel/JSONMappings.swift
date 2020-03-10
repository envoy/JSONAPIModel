//
//  JSONMappings.swift
//  Envoy
//
//  Created by Fang-Pen Lin on 11/2/16.
//  Copyright © 2016 Envoy Inc. All rights reserved.
//

import Foundation
import UIKit

import SwiftyJSON

public extension UIColor {
    convenience init(hexString: String) {
        let scanner = Scanner(string: hexString)
        // bypass '#' character
        scanner.scanLocation = 1
        var rgbValue = UInt32()
        scanner.scanHexInt32(&rgbValue)
        let red = (rgbValue & 0xFF0000) >> 16
        let green = (rgbValue & 0xFF00) >> 8
        let blue = rgbValue & 0xFF
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: 1.0
        )
    }
}

public extension JSON {
    /// Parsed UIColor from `self` JSON object
    ///  - Returns: an UIColor object if it's available, otherwise nil is returned
    var hexColor: UIColor? {
        guard let hex = string else {
            return nil
        }
        return UIColor(hexString: hex)
    }
}
