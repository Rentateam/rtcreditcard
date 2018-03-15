//
//  CvvNumberFormatterMask.swift
//  CHRTextFieldFormatter
//
//  Created by Aleksei Unshchikov on 30.01.2018.
//

import Foundation
import CHRTextFieldFormatter

class CvvNumberFormatterMask: CHRCardNumberMask {
    
    override func shouldChange(_ text: String, withReplacementString string: String, in range: NSRange) -> Bool {
        let newString = NSString(string: text).replacingCharacters(in: range, with: string)
        return newString.count <= 4
    }
    
    override func filteredString(from string: String, cursorPosition: UnsafeMutablePointer<UInt>?) -> String {
        let originalCursorPosition = cursorPosition?.pointee ?? 0
        var digitsOnlyString = ""
        for i in 0..<string.count {
            let characterToAdd = string[string.index(string.startIndex, offsetBy: i)]
            if "0"..."9" ~= characterToAdd {
                digitsOnlyString.append(characterToAdd)
            } else {
                if UInt(bitPattern: i) < originalCursorPosition {
                    if cursorPosition != nil {
                        cursorPosition?.pointee -= 1
                    }
                }
            }
        }
        
        return digitsOnlyString;
    }
    
    override func formattedString(from string: String, cursorPosition: UnsafeMutablePointer<UInt>?) -> String {
        return string
    }
}

