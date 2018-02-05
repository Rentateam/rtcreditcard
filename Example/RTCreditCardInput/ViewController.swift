//
//  ViewController.swift
//  RTCreditCardInput
//
//  Created by Aleksei Unshchikov on 02/01/2018.
//  Copyright (c) 2018 Aleksei Unshchikov. All rights reserved.
//

import UIKit
import RTCreditCardInput

class ViewController: UIViewController, CardCheckDelegateProtocol, CartNumberValidationProtocol {
    
    @IBOutlet weak var tfCardnumber: UITextField!
    @IBOutlet weak var tfCardholder: UITextField!
    @IBOutlet weak var tfDate: UITextField!
    @IBOutlet weak var tfCvv: UITextField!
    
    private var input: RTCreditCardInput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.input = RTCreditCardInput(cardValidation: CardDefaultValidationService(numberValidation: self),
                                       cardValidationDecorator: CardValidationDefaultDecoratorService(),
                                       cardCheckDelegate: self)
        self.input.cardCVVTextField = self.tfCvv
        self.input.cardExpirationDateTextField = self.tfDate
        self.input.cardholderTextField = self.tfCardholder
        self.input.cardNumberTextField = self.tfCardnumber
        self.input.activate()
    }
    
    func onSuccess(){
        print("Successful validation")
    }
    
    func onError(error: RTCreditCardError) {
        print("Validation error: %@", error)
    }
    
    func isCardNumberValid(_ cardNumber: String) -> Bool {
        //just primitive realization
        return cardNumber.count == 16
    }
}

