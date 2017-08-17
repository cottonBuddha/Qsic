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
    
    var count : Int {
        return self.characters.count
    }
    
    var upper : String {
        return self.uppercased()
    }
    
    var lower : String {
        return self.lowercased()
    }
    
    func removeLast() -> String {
        return self.subStr(range: (0,self.characters.count - 1))
    }
    
    func removeFirst() -> String {
        return self.subStr(range: (1,self.characters.count))
    }
    
    func subStr(range:QRange) -> String{
        let lowerIndex = self.index(self.startIndex, offsetBy: range.0)
        let upperIndex = self.index(self.startIndex, offsetBy: range.1)
        let range:Range = Range.init(uncheckedBounds: (lower: lowerIndex, upper: upperIndex))
        return self.substring(with: range)
    }

    
    func matchRegExp(_ pattern:String) -> [String] {
        let regular = try! NSRegularExpression.init(pattern: pattern, options: .caseInsensitive)
        let result = regular.matches(in: self, options: .reportProgress, range: NSMakeRange(0, self.characters.count))
        var resultStr : [String] = []
        result.forEach {
            let range = self.range(from: $0.range)
            let str = self.substring(with: range!)
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
    
}

extension Data {
    
    func jsonDic() -> Any? {
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

    var space : String {
        get {
            return String.init(repeating: " ", count: self)
        }
    }
}



//extension CountableRange where Bound == Int {
//    
//    var random : Int {
//        get {
//            let count = UInt32(self.upperBound - self.lowerBound)
//            return  Int(arc4random_uniform(count)) + self.lowerBound
//        }
//    }
//
//}


