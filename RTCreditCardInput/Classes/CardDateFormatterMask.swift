//
//  CardDateFormatterMask.swift
//  RTCardInput
//
//  Created by Aleksei Unshchikov on 30.01.2018.
//

import Foundation
import CHRTextFieldFormatter

class CardDateFormatterMask: CHRCardNumberMask {
    
    private let kCardFormatterMaskDashFormatted = " / ";
    private let kCardFormatterMaskDashUnformatted = "/";
    private let kCardFormatterMaskDashBackspaceFormatted = " /";

    override func shouldChange(_ text: String!, withReplacementString string: String!, in range: NSRange) -> Bool {
        let isBackSpace = string.count == 0 && range.length == 1
        
        var isPossibleSymbol = false
        if isBackSpace {
            isPossibleSymbol = true
        } else {
            let possibleSymbolsRegex = "[0-9//]";
            isPossibleSymbol = NSPredicate(format: "SELF MATCHES %@", possibleSymbolsRegex).evaluate(with: string)
        }
        
        if !isPossibleSymbol {
            return false
        }
        
        let newString = NSString(string: text).replacingCharacters(in: range, with: string)
        return newString.count <= 7
    }
    
    override func filteredString(from string: String!, cursorPosition: UnsafeMutablePointer<UInt>!) -> String! {
        var result = NSString(string: string).replacingOccurrences(of: kCardFormatterMaskDashFormatted, with: kCardFormatterMaskDashUnformatted)
        result = NSString(string: result).replacingOccurrences(of: kCardFormatterMaskDashBackspaceFormatted, with: kCardFormatterMaskDashUnformatted)
        if cursorPosition != nil {
            cursorPosition.pointee = UInt(result.count)
        }
        return result
    }
    
    override func formattedString(from string: String!, cursorPosition: UnsafeMutablePointer<UInt>!) -> String! {
        var result = ""
        if string.range(of: kCardFormatterMaskDashUnformatted) == nil {
            if string.count < 2 {
                result = string
            } else if string.count == 2 {
                //Добавление разделителя
                result = string + kCardFormatterMaskDashFormatted
            } else if string.count == 3 {
                //Добавление разделителя в середину строки
                let startIndex = string.index(string.startIndex, offsetBy: 2)
                let endIndex = string.index(startIndex, offsetBy: 1)
                let substring1 = String(string![startIndex...])
                let substring2 =  String(string![startIndex...endIndex])
                result = String(format: "%@%@%@", substring1, kCardFormatterMaskDashFormatted, substring2)
            } else {
                result = NSString(string: string).replacingOccurrences(of: kCardFormatterMaskDashUnformatted, with: kCardFormatterMaskDashFormatted)
            }
        } else {
            if string.count == 2 + kCardFormatterMaskDashUnformatted.count {
                result = NSString(string: string).replacingOccurrences(of: kCardFormatterMaskDashUnformatted, with: "")
            } else {
                if string.range(of: kCardFormatterMaskDashFormatted) == nil {
                    if string.range(of: kCardFormatterMaskDashBackspaceFormatted) == nil {
                        result = NSString(string: string).replacingOccurrences(of: kCardFormatterMaskDashUnformatted, with: kCardFormatterMaskDashFormatted)
                    } else {
                        result = NSString(string: string).replacingOccurrences(of: kCardFormatterMaskDashBackspaceFormatted, with: "")
                    }
                } else {
                    result = string
                }
            }
        }
        if cursorPosition != nil {
            cursorPosition.pointee = UInt(result.count)
        }
        return result;
    }

}
