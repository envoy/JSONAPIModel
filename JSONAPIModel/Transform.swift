//
//  TransformType.swift
//  Envoy
//
//  Created by Fang-Pen Lin on 11/9/16.
//  Copyright © 2016 Envoy Inc. All rights reserved.
//

import Foundation

/// Transform is an object allows you to transform given JSON value into desired format,
/// like parsing datetime, hex color and etc
protocol Transform {
    associatedtype ValueType

    /// Transform forward from given value in JSON to value in memory
    ///  - Parameters value: JSON value to be transformed
    ///  - Returns: transformed value
    func forward(_ value: Any?) -> ValueType?

    /// Transform backward from given value in memory to value in JSON
    ///  - Parameters value: memory value to be transformed
    ///  - Returns: transformed JSON value
    func backward(_ value: ValueType?) -> Any?
}

/// Transform for transfroming hex string color to UIColor
struct HexColorTransform: Transform {
    typealias ValueType = UIColor

    func forward(_ value: Any?) -> UIColor? {
        guard let hex = value as? String else {
            return nil
        }
        return UIColor(hexString: hex)
    }

    func backward(_ value: UIColor?) -> Any? {
        guard let color = value else {
            return nil
        }
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        return (NSString(format: "#%06x", rgb) as String)
    }

}

/// Transform for transfroming string to NSURL
struct URLTransform: Transform {
    typealias ValueType = URL

    func forward(_ value: Any?) -> URL? {
        guard let url = value as? String else {
            return nil
        }
        return URL(string: url)
    }

    func backward(_ value: ValueType?) -> Any? {
        guard let url = value else {
            return nil
        }
        return url.absoluteString
    }
}
