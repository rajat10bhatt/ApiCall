//
//  Extensions&Protocols.swift
//  ApiCall
//
//  Created by Rajat Bhatt on 23/06/19.
//  Copyright © 2019 none. All rights reserved.
//

import UIKit

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: .random(), green: .random(), blue: .random(), alpha: 1.0)
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension String {
    static var spaceString: String {
        return " "
    }
    static var emptyString: String {
        return ""
    }
}
