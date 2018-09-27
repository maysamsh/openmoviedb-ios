//
//  UISearchBar+Ext.swift
//  Utility
//
//  Created by Maysam Shahsavari on 7/30/18.
//  Copyright © 2018 Maysam Shahsavari. All rights reserved.
//  Update: September 18, 2018

import Foundation
import UIKit

extension UISearchBar {
    private var textField: UITextField? {
        let subViews = self.subviews.flatMap { $0.subviews }
        return (subViews.filter { $0 is UITextField }).first as? UITextField
    }
    
    private var searchIcon: UIImage? {
        let subViews = subviews.flatMap { $0.subviews }
        return  ((subViews.filter { $0 is UIImageView }).first as? UIImageView)?.image
    }

    private var activityIndicator: UIActivityIndicatorView? {
        return textField?.leftView?.subviews.compactMap{ $0 as? UIActivityIndicatorView }.first
    }
    
    //MARK: - Public API
    
    var isLoading: Bool {
        get {
            return activityIndicator != nil
        } set {
            let _searchIcon = searchIcon
            if newValue {
                if activityIndicator == nil {
                    let _activityIndicator = UIActivityIndicatorView(style: .gray)
                    _activityIndicator.startAnimating()
                    _activityIndicator.backgroundColor = UIColor.clear
                    self.setImage(UIImage(), for: .search, state: .normal)
                    textField?.leftView?.addSubview(_activityIndicator)
                    let leftViewSize = textField?.leftView?.frame.size ?? CGSize.zero
                    _activityIndicator.center = CGPoint(x: leftViewSize.width/2, y: leftViewSize.height/2)
                }
            } else {
                self.setImage(_searchIcon, for: .search, state: .normal)
                activityIndicator?.removeFromSuperview()
            }
        }
    }
}
