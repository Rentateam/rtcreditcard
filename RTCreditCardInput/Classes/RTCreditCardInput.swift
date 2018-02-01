//
//  CardInput.swift
//  TestCardInput
//
//  Created by Aleksei Unshchikov on 30.01.2018.
//  Copyright © 2018 Aleksei Unshchikov. All rights reserved.
//

import UIKit
import CHRTextFieldFormatter

public class RTCreditCardInput: NSObject {
    
    // #todo : deal with it
    public static let kNotificationCardIncorrectNumber = "NotificationCardIncorrectNumber"
    public static let kNotificationCardIncorrectCardholder = "kNotificationCardIncorrectCardholder"
    public static let kNotificationCardIncorrectCVV = "NotificationCardIncorrectCVV"
    public static let kNotificationCardIncorrectDate = "NotificationCardIncorrectDate"
    public static let kNotificationCardInvalid = "NotificationCardInvalid"
    public static let kNotificationCardFormValid = "NotificationCardFormValid"
    
    var cardNumberFormatter: CHRTextFieldFormatter!
    var cardCVVFormatter: CHRTextFieldFormatter!
    var expirationDateFormatter: CHRTextFieldFormatter!
    
    
    public weak var cardNumberTextField: UITextField!
    public weak var cardholderTextField: UITextField!
    public weak var cardExpirationDateTextField: UITextField!
    public weak var cardCVVTextField: UITextField!
    public weak var view: UIView!
    private var cardValidationService: CardValidationServiceProtocol
    
    public init(cardValidationService: CardValidationServiceProtocol) {
        self.cardValidationService = cardValidationService
        // #todo may be get rid of notifications
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCardIncorrectNumber:) name:kNotificationCardIncorrectNumber object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCardIncorrectOwner:) name:kNotificationCardIncorrectOwner object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCardIncorrectCVV:) name:kNotificationCardIncorrectCVV object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCardIncorrectDate:) name:kNotificationCardIncorrectDate object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCardIncorrectNumber:) name:kNotificationCardInvalid object:nil];
    }
    
    
    deinit {
        // #todo
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationCardIncorrectNumber object:nil];
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationCardIncorrectOwner object:nil];
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationCardIncorrectCVV object:nil];
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationCardIncorrectDate object:nil];
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationCardInvalid object:nil];
    }

    public func activate() {
        self.cardNumberTextField.delegate = self
        self.cardholderTextField.delegate = self
        self.cardExpirationDateTextField.delegate = self
        self.cardCVVTextField.delegate = self
    
        self.cardNumberFormatter = CHRTextFieldFormatter(textField: self.cardNumberTextField, mask: CardNumberFormatterMask())
        self.cardCVVFormatter = CHRTextFieldFormatter(textField: self.cardCVVTextField, mask: CvvNumberFormatterMask())
        self.expirationDateFormatter = CHRTextFieldFormatter(textField: self.cardExpirationDateTextField, mask: CardDateFormatterMask())
    }
    
    func setCardNumber(cardNumber: String) {
        self.cardNumberTextField.text = self.cardNumberFormatter.maskedString(from: cardNumber)
    }
    
    func setExpirationDate(expirationDate: String) {
        self.cardExpirationDateTextField.text = self.expirationDateFormatter.maskedString(from: expirationDate)
    }
    
    func setCvv(cvv: String) {
        self.cardCVVTextField.text = self.cardCVVFormatter.maskedString(from: cvv)
    }
    
    func getOwnerError() -> String {
        guard let text = self.cardholderTextField.text else { return "" }
        if text.count > 0 {
            return ""
        } else {
            return RTCreditCardInput.kNotificationCardIncorrectCardholder
        }
    }
    
    func getCVVError() -> String {
        guard let text = self.cardCVVTextField.text else { return "" }
        if text.count == 3 {
            return ""
        } else {
            return RTCreditCardInput.kNotificationCardIncorrectCVV
        }
    }
    
    func processValidation(shouldChangeResponder: Bool) {

        // #todo : deal with ! near 'text'
        let cardNumberError = self.cardValidationService.getCardNumberError(cardNumberString: self.cardNumberFormatter.unmaskedString(from: self.cardNumberTextField.text!))
        if !cardNumberError.isEmpty {
            // #todo
            //[NotificationManager postNotificationThreadSafe:cardNumberError withUserInfo:nil];
            return
        } else if shouldChangeResponder && self.cardNumberTextField.isFirstResponder {
            self.cardholderTextField.becomeFirstResponder()
        }
        let ownerError = self.getOwnerError()
        if !ownerError.isEmpty {
            // #todo
            //[NotificationManager postNotificationThreadSafe:ownerError withUserInfo:nil];
            return
        }
        
        // #todo : deal with ! near 'text'
        let expirationDateError = self.cardValidationService.getExpirationDateError(cardExpirationDateString: self.expirationDateFormatter.unmaskedString(from: self.cardExpirationDateTextField.text!))
        if expirationDateError.isEmpty {
            // #todo
            // [NotificationManager postNotificationThreadSafe:expirationDateError withUserInfo:nil]
            return
        } else if shouldChangeResponder && self.cardExpirationDateTextField.isFirstResponder {
            self.cardCVVTextField.becomeFirstResponder()
        }
        let cvvError = self.getCVVError()
        if !cvvError.isEmpty {
            // #todo
            //[NotificationManager postNotificationThreadSafe:cvvError withUserInfo:nil];
            return
        } else if shouldChangeResponder && self.cardCVVTextField.isFirstResponder {
            self.cardCVVTextField.resignFirstResponder()
        }
        // #todo
        //[NotificationManager postNotificationThreadSafe:kNotificationCardFormValid withUserInfo:nil];
    }
    
    fileprivate func processValidationAsync(shouldChangeResponder: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { self.processValidation(shouldChangeResponder: shouldChangeResponder) })
    }
    
    
    func createCardInfo() -> CardInfo {
        let cardInfo = CardInfo(number: self.cardNumberFormatter.unmaskedString(from: self.cardNumberTextField.text ?? ""),
                                holder: self.cardholderTextField.text ?? "",
                                expirationDate: self.expirationDateFormatter.unmaskedString(from: self.cardExpirationDateTextField.text ?? ""),
                                cvv: self.cardCVVTextField.text ?? "")
        return cardInfo
    }
    
    func decorateTextField(textField: UITextField) {
        textField.layer.cornerRadius = 4.0
        textField.layer.masksToBounds = true
        textField.layer.borderColor = UIColor(red: 217/255.0, green:188/255.0, blue:233/255.0, alpha:1.0).cgColor
        textField.layer.borderWidth = 4.0
    }
    
    func decorateErrorTextField(textField: UITextField) {
        textField.layer.cornerRadius = 4.0
        textField.layer.masksToBounds = true
        textField.layer.borderColor = UIColor(red :255/255.0, green:0/255.0, blue:0/255.0, alpha:1.0).cgColor
        textField.layer.borderWidth = 4.0
    }
    
    func undecorateTextField(textField: UITextField) {
        textField.layer.borderColor = UIColor.clear.cgColor
    }
    
    func onCardIncorrectNumber(notification: Notification) {
        
        if self.cardNumberTextField.isFirstResponder {
            return
        }
        self.decorateErrorTextField(textField: self.cardNumberTextField)
    }
    
    func onCardIncorrectOwner(notification: Notification) {
        if self.cardholderTextField.isFirstResponder {
            return
        }
        self.decorateErrorTextField(textField: self.cardholderTextField)
    }
    
    func onCardIncorrectCVV(notification: Notification) {
        if self.cardCVVTextField.isFirstResponder {
            return
        }
        self.decorateErrorTextField(textField: self.cardCVVTextField)
    }
    
    func onCardIncorrectDate(notification: Notification) {
        guard let text = self.cardExpirationDateTextField.text else {
            return
        }
        if self.cardExpirationDateTextField.isFirstResponder ||
            (self.cardholderTextField.isFirstResponder &&
                text.count == 0) {
            return
        }
        self.decorateErrorTextField(textField: self.cardExpirationDateTextField)
    }
}

extension RTCreditCardInput: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.processValidationAsync(shouldChangeResponder: true)
        var shouldChange = true
        if textField.isEqual(self.cardExpirationDateTextField) {
            shouldChange = self.expirationDateFormatter.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
        } else if (textField == self.cardNumberTextField) {
            shouldChange = self.cardNumberFormatter.textField(textField, shouldChangeCharactersIn: range, replacementString:string)
        } else if (textField == self.cardCVVTextField){
            shouldChange = self.cardCVVFormatter.textField(textField, shouldChangeCharactersIn: range, replacementString:string)
        }
        return shouldChange;
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.decorateTextField(textField: textField)
        self.processValidationAsync(shouldChangeResponder: false)
        return true
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.undecorateTextField(textField: textField)
        self.processValidationAsync(shouldChangeResponder: false)
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isEqual(self.cardNumberTextField) {
            let cardNumberError = self.cardValidationService.getCardNumberError(cardNumberString: self.cardNumberFormatter.unmaskedString(from: self.cardNumberTextField.text ?? ""))
            if !cardNumberError.isEmpty {
                textField.becomeFirstResponder()
                return false
            } else {
                self.cardholderTextField.becomeFirstResponder()
                return true
            }
        } else if textField.isEqual(self.cardholderTextField) {
            let ownerError = self.getOwnerError()
            if !ownerError.isEmpty {
                textField.becomeFirstResponder()
                return false
            } else {
                self.cardExpirationDateTextField.becomeFirstResponder()
                return true
            }
        } else if textField.isEqual(self.cardExpirationDateTextField) {
            let expirationDateError = self.cardValidationService.getExpirationDateError(cardExpirationDateString: self.expirationDateFormatter.unmaskedString(from: self.cardExpirationDateTextField.text ?? ""))
            if !expirationDateError.isEmpty {
                textField.becomeFirstResponder()
                return false
            } else {
                self.cardCVVTextField.becomeFirstResponder()
                return true
            }
        } else if textField.isEqual(self.cardCVVTextField) {
            let cvvError = self.getCVVError()
            if !cvvError.isEmpty {
                textField.becomeFirstResponder()
                return false
            } else {
                self.cardCVVTextField.resignFirstResponder()
                return true
            }
        }
        
        textField.resignFirstResponder()
        return true
    }
}
