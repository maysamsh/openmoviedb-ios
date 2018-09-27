//
//  UIView+Ext.swift
//  Utility
//
//  Created by Maysam Shahsavari on 6/20/18.
//  Copyright © 2018 Maysam Shahsavari. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
