//
//  ViewController.swift
//  RTCreditCardInput
//
//  Created by Aleksei Unshchikov on 02/01/2018.
//  Copyright (c) 2018 Aleksei Unshchikov. All rights reserved.
//

import UIKit
import RTCreditCardInput

class ViewController: UIViewController, CardCheckDelegateProtocol, CartNumberValidationProtocol, UITextFieldDelegate {
    
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
        self.tfCardnumber.delegate = self
        self.tfCardholder.delegate = self
        self.tfDate.delegate = self
        self.tfCvv.delegate = self
        
        self.input.assignTextFields(cardNumberTextField: self.tfCardnumber,
                                    cardholderTextField: self.tfCardholder,
                                    cardExpirationDateTextField: self.tfDate,
                                    cardCVVTextField: self.tfCvv)
        
        
    }
    
    func onSuccess(){
        print("Successful validation, %@, %@, %@, %@",
              self.input.getCardNumber() as Any,
              self.input.getCardOwner() as Any,
              self.input.getExpirationDate() as Any,
              self.input.getCVV() as Any)
    }
    
    func onError(error: RTCreditCardError) {
        print("Validation error: %@", error)
    }
    
    func isCardNumberValid(_ cardNumber: String) -> Bool {
        //just primitive realization
        return cardNumber.count == 16
    }
    
    //Allows to have own textfield delegates
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

