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
    private var cardNumberFormatter: CHRTextFieldFormatter!
    private var cardCVVFormatter: CHRTextFieldFormatter!
    private var expirationDateFormatter: CHRTextFieldFormatter!
    
    private weak var cardNumberTextField: UITextField?
    private weak var cardholderTextField: UITextField?
    private weak var cardExpirationDateTextField: UITextField?
    private weak var cardCVVTextField: UITextField?
    private var cardValidation: CardValidationProtocol
    private var cardValidationDecorator: CardValidationDecoratorProtocol
    private var cardCheckDelegate: CardCheckDelegateProtocol
    private var lastSentError: RTCreditCardError?
    
    public init(cardValidation: CardValidationProtocol, cardValidationDecorator: CardValidationDecoratorProtocol, cardCheckDelegate: CardCheckDelegateProtocol) {
        self.cardValidation = cardValidation
        self.cardValidationDecorator = cardValidationDecorator
        self.cardCheckDelegate = cardCheckDelegate
    }
    
    public func assignTextFields(cardNumberTextField: UITextField?,
                                 cardholderTextField: UITextField?,
                                 cardExpirationDateTextField: UITextField?,
                                 cardCVVTextField: UITextField?) {
        self.cardNumberTextField = cardNumberTextField
        self.cardholderTextField = cardholderTextField
        self.cardExpirationDateTextField = cardExpirationDateTextField
        self.cardCVVTextField = cardCVVTextField
        self.activate()
    }
    
    private func activate() {
        self.cardNumberTextField?.delegate = self
        self.cardholderTextField?.delegate = self
        self.cardExpirationDateTextField?.delegate = self
        self.cardCVVTextField?.delegate = self
    
        self.cardNumberFormatter = CHRTextFieldFormatter(textField: self.cardNumberTextField, mask: CardNumberFormatterMask())
        self.cardCVVFormatter = CHRTextFieldFormatter(textField: self.cardCVVTextField, mask: CvvNumberFormatterMask())
        self.expirationDateFormatter = CHRTextFieldFormatter(textField: self.cardExpirationDateTextField, mask: CardDateFormatterMask())
    }
    
    private func setCardNumber(cardNumber: String) {
        self.cardNumberTextField?.text = self.cardNumberFormatter.maskedString(from: cardNumber)
    }
    
    private func setExpirationDate(expirationDate: String) {
        self.cardExpirationDateTextField?.text = self.expirationDateFormatter.maskedString(from: expirationDate)
    }
    
    private func setCvv(cvv: String) {
        self.cardCVVTextField?.text = self.cardCVVFormatter.maskedString(from: cvv)
    }
    
    private func sendError(_ error: RTCreditCardError?) {
        if self.lastSentError == error {
            return
        }
        self.lastSentError = error
        if error != nil {
            self.cardCheckDelegate.onError(error: error!)
        } else {
            self.cardCheckDelegate.onSuccess()
        }
    }
    
    private func processValidation(shouldChangeResponder: Bool) {
        let cardNumberError = self.cardValidation.getCardNumberError(cardNumberString: self.cardNumberFormatter.unmaskedString(from: (self.cardNumberTextField?.text ?? "")))
        if cardNumberError != nil {
            self.onCardIncorrectNumber()
            self.sendError(RTCreditCardError.kNotificationCardIncorrectNumber)
            return
        } else if shouldChangeResponder && (self.cardNumberTextField?.isFirstResponder ?? false) {
            self.cardholderTextField?.becomeFirstResponder()
        }
        let ownerError = self.cardValidation.getCardHolderError(cardHolderString: self.cardholderTextField?.text ?? "")
        if ownerError != nil {
            self.onCardIncorrectOwner()
            self.sendError(RTCreditCardError.kNotificationCardIncorrectCardholder)
            return
        }
        
        let expirationDateError = self.cardValidation.getExpirationDateError(cardExpirationDateString: self.expirationDateFormatter.unmaskedString(from: (self.cardExpirationDateTextField?.text ?? "")))
        if expirationDateError != nil {
            self.onCardIncorrectDate()
            self.sendError(RTCreditCardError.kNotificationCardIncorrectDate)
            return
        } else if shouldChangeResponder && (self.cardExpirationDateTextField?.isFirstResponder ?? false) {
            self.cardCVVTextField?.becomeFirstResponder()
        }
        let cvvError = self.cardValidation.getCVVError(cvvString: self.cardCVVTextField?.text ?? "")
        if cvvError != nil {
            self.onCardIncorrectCVV()
            self.sendError(RTCreditCardError.kNotificationCardIncorrectCVV)
            return
        } else if shouldChangeResponder && (self.cardCVVTextField?.isFirstResponder ?? false) {
            self.cardCVVTextField?.resignFirstResponder()
        }
        self.sendError(nil)
    }
    
    private var validationWorkItem: DispatchWorkItem?
    
    fileprivate func processValidationAsync(shouldChangeResponder: Bool) {
        self.validationWorkItem?.cancel()
        self.validationWorkItem = DispatchWorkItem() {
            self.processValidation(shouldChangeResponder: shouldChangeResponder)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: self.validationWorkItem!)
    }
    
    private func createCardInfo() -> CardInfo {
        let cardInfo = CardInfo(number: self.cardNumberFormatter.unmaskedString(from: self.cardNumberTextField?.text ?? ""),
                                holder: self.cardholderTextField?.text ?? "",
                                expirationDate: self.expirationDateFormatter.unmaskedString(from: self.cardExpirationDateTextField?.text ?? ""),
                                cvv: self.cardCVVTextField?.text ?? "")
        return cardInfo
    }
    
    
    
    private func onCardIncorrectNumber() {
        guard let cardNumberTextField = self.cardNumberTextField else {
            return
        }
        if cardNumberTextField.isFirstResponder {
            return
        }
        self.cardValidationDecorator.decorateErrorTextField(textField: cardNumberTextField)
    }
    
    private func onCardIncorrectOwner() {
        guard let cardholderTextField = self.cardholderTextField else {
            return
        }
        if cardholderTextField.isFirstResponder {
            return
        }
        self.cardValidationDecorator.decorateErrorTextField(textField: cardholderTextField)
    }
    
    private func onCardIncorrectCVV() {
        guard let cardCVVTextField = self.cardCVVTextField else {
            return
        }
        
        if cardCVVTextField.isFirstResponder {
            return
        }
        self.cardValidationDecorator.decorateErrorTextField(textField: cardCVVTextField)
    }
    
    private func onCardIncorrectDate() {
        guard let cardExpirationDateTextField = self.cardExpirationDateTextField, let text = cardExpirationDateTextField.text else {
            return
        }
        if cardExpirationDateTextField.isFirstResponder ||
            ((self.cardholderTextField?.isFirstResponder ?? false) &&
                text.count == 0) {
            return
        }
        self.cardValidationDecorator.decorateErrorTextField(textField: cardExpirationDateTextField)
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
            let cardNumberError = self.cardValidation.getCardNumberError(cardNumberString: self.cardNumberFormatter.unmaskedString(from: self.cardNumberTextField?.text ?? ""))
            if cardNumberError != nil {
                textField.becomeFirstResponder()
                return false
            } else {
                self.cardholderTextField?.becomeFirstResponder()
                return true
            }
        } else if textField.isEqual(self.cardholderTextField) {
            let ownerError = self.cardValidation.getCardHolderError(cardHolderString: self.cardholderTextField?.text ?? "")
            if ownerError != nil {
                textField.becomeFirstResponder()
                return false
            } else {
                self.cardExpirationDateTextField?.becomeFirstResponder()
                return true
            }
        } else if textField.isEqual(self.cardExpirationDateTextField) {
            let expirationDateError = self.cardValidation.getExpirationDateError(cardExpirationDateString: self.expirationDateFormatter.unmaskedString(from: self.cardExpirationDateTextField?.text ?? ""))
            if expirationDateError != nil {
                textField.becomeFirstResponder()
                return false
            } else {
                self.cardCVVTextField?.becomeFirstResponder()
                return true
            }
        } else if textField.isEqual(self.cardCVVTextField) {
            let cvvError = self.cardValidation.getCVVError(cvvString: self.cardCVVTextField?.text ?? "")
            if cvvError != nil {
                textField.becomeFirstResponder()
                return false
            } else {
                self.cardCVVTextField?.resignFirstResponder()
                return true
            }
        }
        
        textField.resignFirstResponder()
        return true
    }
}
