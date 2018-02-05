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
    var cardNumberFormatter: CHRTextFieldFormatter!
    var cardCVVFormatter: CHRTextFieldFormatter!
    var expirationDateFormatter: CHRTextFieldFormatter!
    
    
    public weak var cardNumberTextField: UITextField!
    public weak var cardholderTextField: UITextField!
    public weak var cardExpirationDateTextField: UITextField!
    public weak var cardCVVTextField: UITextField!
    public weak var view: UIView!
    private var cardValidation: CardValidationProtocol
    private var cardValidationDecorator: CardValidationDecoratorProtocol
    private var cardCheckDelegate: CardCheckDelegateProtocol
    
    public init(cardValidation: CardValidationProtocol, cardValidationDecorator: CardValidationDecoratorProtocol, cardCheckDelegate: CardCheckDelegateProtocol) {
        self.cardValidation = cardValidation
        self.cardValidationDecorator = cardValidationDecorator
        self.cardCheckDelegate = cardCheckDelegate
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
    
    private func setCardNumber(cardNumber: String) {
        self.cardNumberTextField.text = self.cardNumberFormatter.maskedString(from: cardNumber)
    }
    
    private func setExpirationDate(expirationDate: String) {
        self.cardExpirationDateTextField.text = self.expirationDateFormatter.maskedString(from: expirationDate)
    }
    
    private func setCvv(cvv: String) {
        self.cardCVVTextField.text = self.cardCVVFormatter.maskedString(from: cvv)
    }
    
    private func getOwnerError() -> RTCreditCardError? {
        guard let text = self.cardholderTextField.text else { return nil }
        if text.count > 0 {
            return nil
        } else {
            return RTCreditCardError.kNotificationCardIncorrectCardholder
        }
    }
    
    private func getCVVError() -> RTCreditCardError? {
        guard let text = self.cardCVVTextField.text else { return nil }
        if text.count == 3 {
            return nil
        } else {
            return RTCreditCardError.kNotificationCardIncorrectCVV
        }
    }
    
    private func processValidation(shouldChangeResponder: Bool) {

        // #todo : deal with ! near 'text'
        let cardNumberError = self.cardValidation.getCardNumberError(cardNumberString: self.cardNumberFormatter.unmaskedString(from: self.cardNumberTextField.text!))
        if cardNumberError != nil {
            self.onCardIncorrectNumber()
            self.cardCheckDelegate.onError(error: RTCreditCardError.kNotificationCardIncorrectNumber)
            return
        } else if shouldChangeResponder && self.cardNumberTextField.isFirstResponder {
            self.cardholderTextField.becomeFirstResponder()
        }
        let ownerError = self.getOwnerError()
        if ownerError != nil {
            self.onCardIncorrectOwner()
            self.cardCheckDelegate.onError(error: RTCreditCardError.kNotificationCardIncorrectCardholder)
            return
        }
        
        // #todo : deal with ! near 'text'
        let expirationDateError = self.cardValidation.getExpirationDateError(cardExpirationDateString: self.expirationDateFormatter.unmaskedString(from: self.cardExpirationDateTextField.text!))
        if expirationDateError != nil {
            self.onCardIncorrectDate()
            self.cardCheckDelegate.onError(error: RTCreditCardError.kNotificationCardIncorrectDate)
            return
        } else if shouldChangeResponder && self.cardExpirationDateTextField.isFirstResponder {
            self.cardCVVTextField.becomeFirstResponder()
        }
        let cvvError = self.getCVVError()
        if cvvError != nil {
            self.onCardIncorrectCVV()
            self.cardCheckDelegate.onError(error: RTCreditCardError.kNotificationCardIncorrectCVV)
            return
        } else if shouldChangeResponder && self.cardCVVTextField.isFirstResponder {
            self.cardCVVTextField.resignFirstResponder()
        }
        self.cardCheckDelegate.onSuccess()
    }
    
    fileprivate func processValidationAsync(shouldChangeResponder: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { self.processValidation(shouldChangeResponder: shouldChangeResponder) })
    }
    
    
    private func createCardInfo() -> CardInfo {
        let cardInfo = CardInfo(number: self.cardNumberFormatter.unmaskedString(from: self.cardNumberTextField.text ?? ""),
                                holder: self.cardholderTextField.text ?? "",
                                expirationDate: self.expirationDateFormatter.unmaskedString(from: self.cardExpirationDateTextField.text ?? ""),
                                cvv: self.cardCVVTextField.text ?? "")
        return cardInfo
    }
    
    
    
    private func onCardIncorrectNumber() {
        if self.cardNumberTextField.isFirstResponder {
            return
        }
        self.cardValidationDecorator.decorateErrorTextField(textField: self.cardNumberTextField)
    }
    
    private func onCardIncorrectOwner() {
        if self.cardholderTextField.isFirstResponder {
            return
        }
        self.cardValidationDecorator.decorateErrorTextField(textField: self.cardholderTextField)
    }
    
    private func onCardIncorrectCVV() {
        if self.cardCVVTextField.isFirstResponder {
            return
        }
        self.cardValidationDecorator.decorateErrorTextField(textField: self.cardCVVTextField)
    }
    
    private func onCardIncorrectDate() {
        guard let text = self.cardExpirationDateTextField.text else {
            return
        }
        if self.cardExpirationDateTextField.isFirstResponder ||
            (self.cardholderTextField.isFirstResponder &&
                text.count == 0) {
            return
        }
        self.cardValidationDecorator.decorateErrorTextField(textField: self.cardExpirationDateTextField)
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
        self.cardValidationDecorator.decorateTextField(textField: textField)
        self.processValidationAsync(shouldChangeResponder: false)
        return true
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.cardValidationDecorator.undecorateTextField(textField: textField)
        self.processValidationAsync(shouldChangeResponder: false)
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isEqual(self.cardNumberTextField) {
            let cardNumberError = self.cardValidation.getCardNumberError(cardNumberString: self.cardNumberFormatter.unmaskedString(from: self.cardNumberTextField.text ?? ""))
            if cardNumberError != nil {
                textField.becomeFirstResponder()
                return false
            } else {
                self.cardholderTextField.becomeFirstResponder()
                return true
            }
        } else if textField.isEqual(self.cardholderTextField) {
            let ownerError = self.getOwnerError()
            if ownerError != nil {
                textField.becomeFirstResponder()
                return false
            } else {
                self.cardExpirationDateTextField.becomeFirstResponder()
                return true
            }
        } else if textField.isEqual(self.cardExpirationDateTextField) {
            let expirationDateError = self.cardValidation.getExpirationDateError(cardExpirationDateString: self.expirationDateFormatter.unmaskedString(from: self.cardExpirationDateTextField.text ?? ""))
            if expirationDateError != nil {
                textField.becomeFirstResponder()
                return false
            } else {
                self.cardCVVTextField.becomeFirstResponder()
                return true
            }
        } else if textField.isEqual(self.cardCVVTextField) {
            let cvvError = self.getCVVError()
            if cvvError != nil {
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
