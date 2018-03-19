//
//  extension.swift
//  Qsic
//
//  Created by 江齐松 on 2017/7/17.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation

typealias QRange = (Int,Int)

extension String {
    
    var upper : String {
        return self.uppercased()
    }
    
    var lower : String {
        return self.lowercased()
    }
    
    func removeLastCharacter() -> String {
        return self.subStr(range: (0,self.count - 1))
    }
    
    func removeFirstCharacter() -> String {
        return self.subStr(range: (1,self.count))
    }
    
    func subStr(range:QRange) -> String{
        let lowerIndex = self.index(self.startIndex, offsetBy: range.0)
        let upperIndex = self.index(self.startIndex, offsetBy: range.1)
        return String(self[lowerIndex..<upperIndex])
    }

    func matchRegExp(_ pattern:String) -> [String] {
        let regular = try! NSRegularExpression.init(pattern: pattern, options: .caseInsensitive)
        let result = regular.matches(in: self, options: .reportProgress, range: NSMakeRange(0, self.count))
        var resultStr : [String] = []
        result.forEach {
            let range = self.range(from: $0.range)
            let str = self.substring(with: range!)
//            let str = String(self[range...])
            resultStr.append(str)
        }
        return resultStr
    }
    
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
    
    func lengthInCurses() -> Int {
        guard self.count > 0 else {return 0}
        
        var number = 0
        for i in 0...self.count - 1 {
            let c: unichar = (self as NSString).character(at: i)
            
            if (c >= 0x00A4) {
                number += 2
            }else {
                number += 1
            }
        }
        return number
    }
}

extension Data {
    
    func jsonObject() -> Any? {
        if let dic = try? JSONSerialization.jsonObject(with: self, options: .allowFragments) as! [String : Any] {
            return dic
        } else {
            return nil
        }
    }
}

extension Array {
    
    func split(num:Int) -> [Array] {
        if num >= self.count {
            return [self]
        }
        
        var splitArr : [Array] = []
        var subArr : [Element] = []
        var index = 0
        
        self.forEach {
            index = index + 1
            subArr.append($0)

            if index >= num {
                index = 0
                splitArr.append(subArr)
                subArr = []
            }
        }
        if subArr.count > 0 {
            splitArr.append(subArr)
            subArr = []
        }
        return splitArr
    }
    
}

extension Int {

    var space: String {
        get {
            return String.init(repeating: " ", count: self)
        }
    }
    
    var m: Int {
        get {
            return self * 60
        }
    }
    
    var h: Int {
        get {
            return self * 60 * 60
        }
    }
    
    func delay(task: @escaping () -> Void) {
        let delayTime = DispatchTime.now() + .seconds(self)
        DispatchQueue.main.asyncAfter(deadline: delayTime, execute: task)
    }
    
}

extension CountableRange where Bound == Int {
    
    var random : Int {
        get {
            let count = UInt32(self.upperBound - self.lowerBound)
            return  Int(arc4random_uniform(count)) + self.lowerBound
        }
    }

}

extension Dictionary where Key == String {
    
    func getString(key: String) -> String {
        if let str = self[key] as? String {
            return str
        }
        return ""
    }
    
    func optString(key: String) -> String? {
        if let str = self[key] as? String {
            return str
        }
        return nil
    }
    
    func getNumber(key: String) -> NSNumber {
        if let num = self[key] as? NSNumber {
            return num
        }
        return 0
    }
    
    func optNumber(key: String) -> NSNumber? {
        if let num = self[key] as? NSNumber {
            return num
        }
        return nil
    }
    
    func getDictionary(key: String) -> Dictionary {
        if let dic = self[key] as? Dictionary {
            return dic
        }
        return [:]
    }
    
    func optDictionary(key: String) -> Dictionary? {
        if let dic = self[key] as? Dictionary {
            return dic
        }
        return nil
    }
    
    func getArray(key: String) -> Array<Any> {
        if let arr = self[key] as? Array<Any> {
            return arr
        }
        return []
    }
    
    func optArray(key: String) -> Array<Any>? {
        if let arr = self[key] as? Array<Any> {
            return arr
        }
        return nil
    }
}

