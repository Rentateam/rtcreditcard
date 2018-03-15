//
//  CardDefaultValidationService.swift
//  CHRTextFieldFormatter
//
//  Created by A-25 on 05/02/2018.
//

import Foundation

public class CardDefaultValidationService: CardValidationProtocol {
    
    private var numberValidation: CartNumberValidationProtocol
    
    public init(numberValidation: CartNumberValidationProtocol) {
        self.numberValidation = numberValidation
    }
    
    public func getExpirationDateError(cardExpirationDateString: String) -> RTCreditCardError? {
        if cardExpirationDateString.count < 5 {
            return .incorrectDate
        }
        let dateComponents = cardExpirationDateString.split(separator: "/")
        if dateComponents.count == 2 {
            let date = Date()
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.year, .month], from: date)
            let currentMonth = components.month!
            let yearString = String(format: "%ld", Int64(components.year!))
            let index = yearString.index(yearString.startIndex, offsetBy: 2)
            let currentYear = Int(String(yearString[index...]))!
            
            guard let inputedYear = Int(dateComponents[1]) else {
                return .incorrectDate
            }
            
            guard let inputedMonth = Int(dateComponents[0]) else {
                return .incorrectDate
            }
            
            if inputedMonth > 12 {
                return .incorrectDate
            }
            
            if inputedYear < currentYear {
                return .cardExpired
            }
            
            if inputedMonth < currentMonth && inputedYear <= currentYear {
                return .cardExpired
            }
            
            if inputedYear > currentYear + 10 {
                return .incorrectDate
            }
            
            if inputedMonth > currentMonth && inputedYear >= currentYear + 10 {
                return .incorrectDate
            }
        }
        return nil
    }
    
    public func getCardNumberError(cardNumberString: String) -> RTCreditCardError? {
        if !self.numberValidation.isCardNumberValid(cardNumberString) {
            return .incorrectNumber
        }
        return nil
    }
    
    public func getCardHolderError(cardHolderString: String) -> RTCreditCardError? {
        if cardHolderString.count > 0 {
            return nil
        } else {
            return .incorrectCardholder
        }
    }
    
    public func getCVVError(cardNumberString:String, cvvString: String) -> RTCreditCardError? {
        if (cardNumberString.starts(with: "3") && cvvString.count == 4) || (!cardNumberString.starts(with: "3") && cvvString.count == 3) {
            return nil
        } else {
            return .incorrectCVV
        }
    }
}

