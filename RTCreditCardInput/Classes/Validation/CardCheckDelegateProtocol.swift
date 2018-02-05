//
//  CardCheckDelegateProtocol.swift
//  CHRTextFieldFormatter
//
//  Created by A-25 on 05/02/2018.
//

import Foundation

public protocol CardCheckDelegateProtocol {
    func onSuccess()
    func onError(error: RTCreditCardError)
}
