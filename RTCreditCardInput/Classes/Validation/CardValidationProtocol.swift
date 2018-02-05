//
//  CardValidationProtocol.swift
//  TestCardInput
//
//  Created by Aleksei Unshchikov on 30.01.2018.
//  Copyright © 2018 Aleksei Unshchikov. All rights reserved.
//

import Foundation

public protocol CardValidationProtocol {
    func getExpirationDateError(cardExpirationDateString: String) -> RTCreditCardError?
    func getCardNumberError(cardNumberString: String) -> RTCreditCardError?
//    func getCardNumberError(cardNumberString: String, shouldBeValidNumber: Bool) -> String?
}
