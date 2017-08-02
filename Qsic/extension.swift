//
//  extension.swift
//  Qsic
//
//  Created by 江齐松 on 2017/7/17.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation

extension String {
    
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



