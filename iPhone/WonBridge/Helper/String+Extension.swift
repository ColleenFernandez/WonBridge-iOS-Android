//
//  String+Extension.swift
//  WonBridge
//
//  Created by July on 2016-09-24.
//  Copyright © 2016 elitedev. All rights reserved.
//

import Foundation

extension String {
    
    func stringHeightWithMaxWidth(maxWidth: CGFloat, font: UIFont) -> CGFloat {
        let attributes: [String : AnyObject] = [
            NSFontAttributeName: font,
            ]
        let size: CGSize = self.boundingRectWithSize(
            CGSize(width: maxWidth, height: CGFloat.max),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: attributes,
            context: nil
            ).size
        return size.height
    }
    
    func toBool() -> Bool {
        
        switch self {
        case "True", "true", "yes", "1":
            return true
            
        case "False", "flase", "no", "0":
            return false
            
        default:
            return false
        }
    }
    
    func capitalizingFirstLetter() -> String {
        
        let first = String(characters.prefix(1)).uppercaseString
        let other = String(characters.dropFirst())
        
        return first + other
    }
    
    func encodeString() -> String? {
        
        let customAllowedSet =  NSCharacterSet(charactersInString:"!*'();:@&=+$,/?%#[] ").invertedSet
        return stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)
    }
    
    /**
     Returns a percent-escaped string following RFC 3986 for a query string key or value.
     RFC 3986 states that the following characters are "reserved" characters.
     - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
     - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
     In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
     query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
     should be percent-escaped in the query string.
     - parameter string: The string to be percent-escaped.
     - returns: The percent-escaped string.
     */
    func escape(string: String) -> String {
        
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        let allowedCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet
        allowedCharacterSet.removeCharactersInString(generalDelimitersToEncode + subDelimitersToEncode)
        
        var escaped = ""
        
        //==========================================================================================================
        //
        //  Batching is required for escaping due to an internal bug in iOS 8.1 and 8.2. Encoding more than a few
        //  hundred Chinese characters causes various malloc error crashes. To avoid this issue until iOS 8 is no
        //  longer supported, batching MUST be used for encoding. This introduces roughly a 20% overhead. For more
        //  info, please refer to:
        //
        //      - https://github.com/Alamofire/Alamofire/issues/206
        //
        //==========================================================================================================
        
        if #available(iOS 8.3, OSX 10.10, *) {
            escaped = string.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) ?? string
        } else {
            let batchSize = 50
            var index = string.startIndex
            
            while index != string.endIndex {
                let startIndex = index
                let endIndex = index.advancedBy(batchSize, limit: string.endIndex)
                let range = startIndex..<endIndex
                
                let substring = string.substringWithRange(range)
                
                escaped += substring.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet) ?? substring
                
                index = endIndex
            }
        }
        
        return escaped
    }
    
    func isValidEmailAddress() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(self)
    }
    
    func isValidPhoneNumber() -> Bool {
        let PHONE_REGEX = "[A-Z0-9a-z]+"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluateWithObject(self)
        
        if result {
            if self.characters.count < 6 || self.characters.count > 12 {
                return false
            } else {
                return true
            }
        } else {
            return result
        }
    }
    
    // change utc timezone string to local timezone string
    func utc2Local() -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd,H:mm:ss"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        
        let utcDate = dateFormatter.dateFromString(self)
        
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let localDateStr = dateFormatter.stringFromDate(utcDate!)
        
        return localDateStr
    }
    
    func convertTimeString() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd H:mm:ss"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        
        let utcDate = dateFormatter.dateFromString(self)
        
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyyMMdd,H:mm:ss"
        let convertedStr = dateFormatter.stringFromDate(utcDate!)
        
        return convertedStr
    }
    
    // utc timezone string to local timezone string with display format
    func displayLocalTime() -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        
        let date = dateFormatter.dateFromString(self)
        
        let calendar = NSCalendar.currentCalendar()
        return calendar.dateByAddingComponents(NSDateComponents(), toDate: date!, options: [])!.timeAgo
    }
    
    // utc time string to local timezone string with display format
    func displayRegTime() -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        
        let date = dateFormatter.dateFromString(self)
        
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        
        let dateString = dateFormatter.stringFromDate(date!)
        
        return dateString
    }
    
    func fileNamFromUrl() -> String {
        
        let arrPath = self.componentsSeparatedByString("/")
        return arrPath[arrPath.count - 1]
    }
}

extension UIFont {
    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
        return NSString(string: string).boundingRectWithSize(CGSize(width: width, height: DBL_MAX),
                                                             options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                                                             attributes: [NSFontAttributeName: self],
                                                             context: nil).size
    }
}
