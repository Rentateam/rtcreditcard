//
//  CardValidationServiceProtocol.swift
//  TestCardInput
//
//  Created by Aleksei Unshchikov on 30.01.2018.
//  Copyright © 2018 Aleksei Unshchikov. All rights reserved.
//

import Foundation

public protocol CardValidationServiceProtocol {
    func getExpirationDateError(cardExpirationDateString: String) -> String
    func getCardNumberError(cardNumberString: String) -> String
    func getCardNumberError(cardNumberString: String, shouldBeValidNumber: Bool) -> String

}
