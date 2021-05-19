//
//  Utils.swift
//  MyGPS
//
//  Created by sungbin Kim on 2021/04/29.
//

import UIKit

public func getSimpleAlert(title: String, message: String) -> UIAlertController {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "확인", style: .default, handler: nil)
    alertController.addAction(action)
    
    return alertController
}
