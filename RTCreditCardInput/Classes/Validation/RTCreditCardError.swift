//
//  RTCreditCardError.swift
//  CHRTextFieldFormatter
//
//  Created by A-25 on 05/02/2018.
//

import Foundation

public enum RTCreditCardError: String {
    case kNotificationCardIncorrectNumber = "NotificationCardIncorrectNumber"
    case kNotificationCardIncorrectCardholder = "kNotificationCardIncorrectCardholder"
    case kNotificationCardIncorrectCVV = "NotificationCardIncorrectCVV"
    case kNotificationCardIncorrectDate = "NotificationCardIncorrectDate"
    case kNotificationCardInvalid = "NotificationCardInvalid"
    case kNotificationCardFormValid = "NotificationCardFormValid"
}
