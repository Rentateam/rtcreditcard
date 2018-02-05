//
//  CardValidationDefaultDecoratorService.swift
//  CHRTextFieldFormatter
//
//  Created by A-25 on 05/02/2018.
//

import Foundation

public class CardValidationDefaultDecoratorService: CardValidationDecoratorProtocol {
    public func decorateTextField(textField: UITextField) {
        textField.layer.cornerRadius = 4.0
        textField.layer.masksToBounds = true
        textField.layer.borderColor = UIColor(red: 217/255.0, green:188/255.0, blue:233/255.0, alpha:1.0).cgColor
        textField.layer.borderWidth = 4.0
    }
    
    public func decorateErrorTextField(textField: UITextField) {
        textField.layer.cornerRadius = 4.0
        textField.layer.masksToBounds = true
        textField.layer.borderColor = UIColor(red :255/255.0, green:0/255.0, blue:0/255.0, alpha:1.0).cgColor
        textField.layer.borderWidth = 4.0
    }
    
    public func undecorateTextField(textField: UITextField) {
        textField.layer.borderColor = UIColor.clear.cgColor
    }
}
