//
//  CardDefaultValidationService.swift
//  CHRTextFieldFormatter
//
//  Created by A-25 on 05/02/2018.
//

import Foundation

public class CardDefaultValidationService: CardValidationProtocol {
    
    private var numberValidation: CartNumberValidationProtocol
    
    init(numberValidation: CartNumberValidationProtocol) {
        self.numberValidation = numberValidation
    }
    
    public func getExpirationDateError(cardExpirationDateString: String) -> RTCreditCardError? {
        if cardExpirationDateString.count < 5 {
             return RTCreditCardError.kNotificationCardIncorrectDate
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
                return RTCreditCardError.kNotificationCardIncorrectDate
            }
            
            if inputedYear < currentYear {
                return RTCreditCardError.kNotificationCardIncorrectDate
            }
            
            guard let inputedMonth = Int(dateComponents[0]) else {
                return RTCreditCardError.kNotificationCardIncorrectDate
            }
            
            if inputedMonth > 12 {
                return RTCreditCardError.kNotificationCardIncorrectDate
            }
            
            if inputedMonth < currentMonth && inputedYear <= currentYear {
                return RTCreditCardError.kNotificationCardIncorrectDate
            }
        }
        return nil
    }
    
    public func getCardNumberError(cardNumberString: String) -> RTCreditCardError? {
        return self.getCardNumberError(cardNumberString: cardNumberString, shouldBeValidNumber: true)
    }
    
    private func getCardNumberError(cardNumberString: String, shouldBeValidNumber: Bool) -> RTCreditCardError? {
        // supposed to be implementation of card number validation here
        //        if shouldBeValidNumber && ![CPService isCardNumberValid:cardNumberString]){
        //            return kNotificationCardIncorrectNumber;
        //        }
        //        if cardNumberString.count == 16 {
            //        return nil
            //    } else {
            //    return RTCreditCardError.kNotificationCardIncorrectNumber
            //    }
        
        if shouldBeValidNumber && !self.numberValidation.isCardNumberValid(cardNumberString) {
            return RTCreditCardError.kNotificationCardIncorrectNumber
        }
        return nil
    }
}
