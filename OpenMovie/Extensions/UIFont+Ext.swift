//
//  UIFont+Ext.swift
//  Utility
//
//  Created by Maysam Shahsavari on 9/17/18.
//  Copyright © 2018 Maysam Shahsavari. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    class func preferredItalicFont(forTextStyle style: UIFont.TextStyle) -> UIFont? {
        return UIFont.preferredFont(forTextStyle: style).italicisedVariant
    }
    
    var italicisedVariant: UIFont? {
        guard let italicDescriptor = fontDescriptor.withSymbolicTraits(.traitItalic) else { return nil }
        return UIFont(descriptor: italicDescriptor, size: pointSize)
    }
    
    class func preferredBoldFont(forTextStyle style: UIFont.TextStyle) -> UIFont? {
        return UIFont.preferredFont(forTextStyle: style).boldVariant
    }
    
    var boldVariant: UIFont? {
        guard let boldDescriptor = fontDescriptor.withSymbolicTraits(.traitBold) else { return nil }
        return UIFont(descriptor: boldDescriptor, size: pointSize)
    }
}
