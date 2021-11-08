//
//  UIViewController+AlertController.swift
//  PixelPalette
//
//  Created by Sue Cho on 2021/11/09.
//

import UIKit
import AudioToolbox

extension UIViewController {
    typealias ConfirmHandler = (UIAlertAction) -> ()
    
    func defaultAlertController(title: String,
                             message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm".localize(), style: .default, handler: nil)
        
        alert.addAction(confirmAction)
        present(alert, animated: true)
    }
    
    func presentDestructiveAlert(title: String,
                                 message: String,
                                 confirmHandler: @escaping ConfirmHandler) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm".localize(), style: .default, handler: confirmHandler)
        let cancelAction = UIAlertAction(title: "Cancel".localize(), style: .destructive)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func presentTextFieldAlert(title: String,
                               message: String?,
                               placeholder: String,
                               saveHandler: @escaping (String) -> ()) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Save".localize(), style: .default) { [weak self] _ in
            guard let self = self,
                  let text = alert.textFields?[0].text else { return }
            
            if text.isEmpty {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                self.view.makeToast("Give a Name to Save the Color".localize())
            } else {
                saveHandler(text)
                self.view.makeToast("Saved".localize())
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel".localize(), style: .destructive)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = placeholder.localize()
        }
        present(alert, animated: false, completion: nil)
    }
}
