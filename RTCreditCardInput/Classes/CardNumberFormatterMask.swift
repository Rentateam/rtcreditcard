//
//  CardNumberFormatterMask.swift
//  CHRTextFieldFormatter
//
//  Created by Aleksei Unshchikov on 30.01.2018.
//

import Foundation
import CHRTextFieldFormatter

class CardNumberFormatterMask: CHRCardNumberMask {
    
    override func shouldChange(_ text: String, withReplacementString string: String, in range: NSRange) -> Bool {
        let newString = NSString(string: text).replacingCharacters(in: range, with: string)
        return newString.count <= 24
    }
    
    override func formattedString(from string: String, cursorPosition: UnsafeMutablePointer<UInt>?) -> String {
        var stringWithAddedSpaces = ""
        let cursorPositionInSpacelessString = cursorPosition?.pointee ?? 0
        for i in 0..<string.count {
            if (i > 0) && ((i % 4) == 0) {
                stringWithAddedSpaces.append(" ")
                if UInt(bitPattern: i) < cursorPositionInSpacelessString {
                    if cursorPosition != nil {
                        cursorPosition?.pointee += 1
                    }
                }
            }
            let characterToAdd = string[string.index(string.startIndex, offsetBy: i)]
            stringWithAddedSpaces.append(characterToAdd)
        }
        
        return stringWithAddedSpaces;
    }
}
