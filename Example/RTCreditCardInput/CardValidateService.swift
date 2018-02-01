//
//  CardValidateService.swift
//  RTCardInput
//
//  Created by Aleksei Unshchikov on 31.01.2018.
//

import Foundation
import RTCreditCardInput

class CardValidationService: CardValidationServiceProtocol {
    func getExpirationDateError(cardExpirationDateString: String) -> String {
        if cardExpirationDateString.count < 5 {
            // #todo
            return RTCreditCardInput.kNotificationCardIncorrectDate
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
                return RTCreditCardInput.kNotificationCardIncorrectDate
            }
            
            if inputedYear < currentYear {
                return RTCreditCardInput.kNotificationCardIncorrectDate
            }
            
            guard let inputedMonth = Int(dateComponents[0]) else {
                return RTCreditCardInput.kNotificationCardIncorrectDate
            }
            
            if inputedMonth > 12 {
                return RTCreditCardInput.kNotificationCardIncorrectDate
            }
            
            if inputedMonth < currentMonth && inputedYear <= currentYear {
                return RTCreditCardInput.kNotificationCardIncorrectDate
            }
        }
        return ""
    }
    
    func getCardNumberError(cardNumberString: String) -> String {
        return self.getCardNumberError(cardNumberString: cardNumberString, shouldBeValidNumber: true)
    }
    
    func getCardNumberError(cardNumberString: String, shouldBeValidNumber: Bool) -> String {
        // supposed to be implementation of card number validation here
//        if shouldBeValidNumber && ![CPService isCardNumberValid:cardNumberString]){
//            return kNotificationCardIncorrectNumber;
//        }
        
        if cardNumberString.count == 16 {
            return ""
        } else {
            return RTCreditCardInput.kNotificationCardIncorrectNumber
        }
    }

}
