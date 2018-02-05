//
//  CardValidationDecoratorProtocol.swift
//  CHRTextFieldFormatter
//
//  Created by A-25 on 05/02/2018.
//

import Foundation
import UIKit

public protocol CardValidationDecoratorProtocol {
    func decorateTextField(textField: UITextField)
    func decorateErrorTextField(textField: UITextField)
    func undecorateTextField(textField: UITextField)
}

