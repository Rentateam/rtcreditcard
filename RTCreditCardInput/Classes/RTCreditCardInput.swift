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
    fileprivate var cardNumberFormatter: CHRTextFieldFormatter!
    fileprivate var cardCVVFormatter: CHRTextFieldFormatter!
    fileprivate var expirationDateFormatter: CHRTextFieldFormatter!
    
    fileprivate weak var cardNumberTextField: UITextField?
    fileprivate weak var cardholderTextField: UITextField?
    fileprivate weak var cardExpirationDateTextField: UITextField?
    fileprivate weak var cardCVVTextField: UITextField?
    fileprivate var cardNumberOuterDelegate: UITextFieldDelegate?
    fileprivate var cardHolderOuterDelegate: UITextFieldDelegate?
    fileprivate var cardExpirationDateOuterDelegate: UITextFieldDelegate?
    fileprivate var cardCvvOuterDelegate: UITextFieldDelegate?
    fileprivate var cardValidation: CardValidationProtocol
    fileprivate var cardValidationDecorator: CardValidationDecoratorProtocol
    fileprivate var cardCheckDelegate: CardCheckDelegateProtocol
    private var validationWorkItem: DispatchWorkItem?
    private var textFieldChanged: [UITextField: Bool] = [:]
    
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
        for textField in [cardNumberTextField, cardholderTextField, cardExpirationDateTextField, cardCVVTextField] {
            textField?.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        }
        self.activate()
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        self.textFieldChanged[textField] = true
    }
    
    public func getCardNumber() -> String? {
        if let cardText = self.cardNumberTextField?.text {
            return self.cardNumberFormatter.unmaskedString(from: cardText)
        } else {
            return nil
        }
    }
    
    public func getCardOwner() -> String? {
        return self.cardholderTextField?.text
    }
    
    public func getExpirationDate() -> String? {
        if let dateText = self.cardExpirationDateTextField?.text {
            return self.expirationDateFormatter.unmaskedString(from: dateText)
        } else {
            return nil
        }
    }
    
    public func getCVV() -> String? {
        return self.cardCVVTextField?.text
    }
    
    private func activate() {
        //Store outer delegates to emit their methods
        self.cardNumberOuterDelegate = self.cardNumberTextField?.delegate
        self.cardHolderOuterDelegate = self.cardholderTextField?.delegate
        self.cardExpirationDateOuterDelegate = self.cardExpirationDateTextField?.delegate
        self.cardCvvOuterDelegate = self.cardCVVTextField?.delegate
        
        self.cardNumberTextField?.delegate = self
        self.cardholderTextField?.delegate = self
        self.cardExpirationDateTextField?.delegate = self
        self.cardCVVTextField?.delegate = self
        
        self.cardNumberFormatter = CHRTextFieldFormatter(textField: self.cardNumberTextField, mask: CardNumberFormatterMask())
        self.cardCVVFormatter = CHRTextFieldFormatter(textField: self.cardCVVTextField, mask: CvvNumberFormatterMask())
        self.expirationDateFormatter = CHRTextFieldFormatter(textField: self.cardExpirationDateTextField, mask: CardDateFormatterMask())
    }
    
    public func setCardNumber(cardNumber: String) {
        self.cardNumberTextField?.text = self.cardNumberFormatter.maskedString(from: cardNumber)
        self.processValidation(shouldChangeResponder: false)
    }
    
    public func setExpirationDate(expirationDate: String) {
        self.cardExpirationDateTextField?.text = self.expirationDateFormatter.maskedString(from: expirationDate)
        self.processValidation(shouldChangeResponder: false)
    }
    
    public func setCvv(cvv: String) {
        self.cardCVVTextField?.text = self.cardCVVFormatter.maskedString(from: cvv)
        self.processValidation(shouldChangeResponder: false)
    }
    
    private func sendError(_ error: RTCreditCardError?) {
        if error != nil {
            self.cardCheckDelegate.onError(error: error!)
        } else {
            self.cardCheckDelegate.onSuccess()
        }
    }
    
    private func getCardNumberValue() -> String? {
        return self.cardNumberTextField != nil && self.textFieldChanged[self.cardNumberTextField!] == true ? self.cardNumberFormatter.unmaskedString(from: (self.cardNumberTextField?.text ?? "")) : nil
    }
    
    private func getDateExpirationValue() -> String? {
        return self.cardExpirationDateTextField != nil && self.textFieldChanged[self.cardExpirationDateTextField!] == true ? self.expirationDateFormatter.unmaskedString(from: (self.cardExpirationDateTextField?.text ?? "")) : nil
    }
    
    private func getCardHolderValue() -> String? {
        return self.cardholderTextField != nil && self.textFieldChanged[self.cardholderTextField!] == true ? (self.cardholderTextField?.text ?? "") : nil
    }
    
    private func getCvvValue() -> String? {
        return self.cardCVVTextField != nil && self.textFieldChanged[self.cardCVVTextField!] == true ? (self.cardCVVTextField?.text ?? "") : nil
    }
    
    private func processValidation(shouldChangeResponder: Bool) {
        let cardNumberError = self.cardValidation.getCardNumberError(cardNumberString: self.getCardNumberValue())
        if cardNumberError != nil {
            self.onCardIncorrectNumber()
            self.sendError(.incorrectNumber)
            return
        } else if shouldChangeResponder && (self.cardNumberTextField?.isFirstResponder ?? false) {
            if self.cardholderTextField != nil {
                self.cardholderTextField?.becomeFirstResponder()
            } else {
                self.cardExpirationDateTextField?.becomeFirstResponder()
            }
        }
        if self.cardholderTextField != nil {
            let ownerError = self.cardValidation.getCardHolderError(cardHolderString: self.getCardHolderValue())
            if ownerError != nil {
                self.onCardIncorrectOwner()
                self.sendError(.incorrectCardholder)
                return
            }
        }
        
        let expirationDateError = self.cardValidation.getExpirationDateError(cardExpirationDateString: self.getDateExpirationValue())
        if expirationDateError != nil {
            self.onCardIncorrectDate()
            self.sendError(expirationDateError)
            return
        } else if shouldChangeResponder && (self.cardExpirationDateTextField?.isFirstResponder ?? false) {
            self.cardCVVTextField?.becomeFirstResponder()
        }
        
        let cvvError = self.cardValidation.getCVVError(cardNumberString: self.getCardNumberValue(),
                                                       cvvString: self.getCvvValue())
        if cvvError != nil {
            self.onCardIncorrectCVV()
            self.sendError(.incorrectCVV)
            return
        } else if shouldChangeResponder && (self.cardCVVTextField?.isFirstResponder ?? false) {
            self.cardCVVTextField?.resignFirstResponder()
        }
        self.sendError(nil)
    }
    
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
    
    private func getOuterDelegate(for textField: UITextField) -> UITextFieldDelegate? {
        if textField.isEqual(self.cardNumberTextField) {
            return self.cardNumberOuterDelegate
        } else if textField.isEqual(self.cardholderTextField) {
            return self.cardHolderOuterDelegate
        } else if textField.isEqual(self.cardExpirationDateTextField) {
            return self.cardExpirationDateOuterDelegate
        } else if textField.isEqual(self.cardCVVTextField) {
            return self.cardCvvOuterDelegate
        }
        return nil
    }
    
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
        if let delegateMethod = self.getOuterDelegate(for: textField)?.textField {
            return shouldChange && delegateMethod(textField, range, string)
        } else {
            return shouldChange
        }
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.cardValidationDecorator.decorateTextField(textField: textField)
        self.processValidationAsync(shouldChangeResponder: false)
        if let textFieldShouldBeginEditing = self.getOuterDelegate(for: textField)?.textFieldShouldBeginEditing {
            return textFieldShouldBeginEditing(textField)
        } else {
            return true
        }
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.cardValidationDecorator.undecorateTextField(textField: textField)
        self.processValidationAsync(shouldChangeResponder: false)
        if let textFieldShouldEndEditing = self.getOuterDelegate(for: textField)?.textFieldShouldEndEditing {
            return textFieldShouldEndEditing(textField)
        } else {
            return true
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var returnResult: Bool
        if textField.isEqual(self.cardNumberTextField) {
            let cardNumberError = self.cardValidation.getCardNumberError(cardNumberString: self.getCardNumberValue())
            if cardNumberError != nil {
                textField.becomeFirstResponder()
                returnResult = false
            } else {
                if self.cardholderTextField != nil {
                    self.cardholderTextField?.becomeFirstResponder()
                } else {
                    self.cardExpirationDateTextField?.becomeFirstResponder()
                }
                returnResult = true
            }
        } else if textField.isEqual(self.cardholderTextField) {
            let ownerError = self.cardValidation.getCardHolderError(cardHolderString: self.getCardHolderValue())
            if ownerError != nil {
                textField.becomeFirstResponder()
                returnResult = false
            } else {
                self.cardExpirationDateTextField?.becomeFirstResponder()
                returnResult = true
            }
        } else if textField.isEqual(self.cardExpirationDateTextField) {
            let expirationDateError = self.cardValidation.getExpirationDateError(cardExpirationDateString: self.getDateExpirationValue())
            if expirationDateError != nil {
                textField.becomeFirstResponder()
                returnResult = false
            } else {
                self.cardCVVTextField?.becomeFirstResponder()
                returnResult = true
            }
        } else if textField.isEqual(self.cardCVVTextField) {
            let cvvError = self.cardValidation.getCVVError(cardNumberString: self.getCardNumberValue(),
                                                           cvvString: self.getCvvValue())
            if cvvError != nil {
                textField.becomeFirstResponder()
                returnResult = false
            } else {
                self.cardCVVTextField?.resignFirstResponder()
                returnResult = true
            }
        } else {
            returnResult = true
        }
        
        textField.resignFirstResponder()
        if let textFieldShouldReturn = self.getOuterDelegate(for: textField)?.textFieldShouldReturn {
            return returnResult && textFieldShouldReturn(textField)
        } else {
            return returnResult
        }
    }
}
