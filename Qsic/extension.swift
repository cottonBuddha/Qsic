//
//  extension.swift
//  Qsic
//
//  Created by 江齐松 on 2017/7/17.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation

extension String {
    
    func matchRegExp(_ pattern:String) -> Bool {
        let regular = try! NSRegularExpression.init(pattern: pattern, options: .caseInsensitive)
        let result = regular.matches(in: self, options: .reportProgress, range: NSMakeRange(0, self.characters.count))
        if result.count > 0 {return true}
        return false
    }
    
}

extension Data {
    
    func jsonDic() -> [String : Any]? {
        if let dic = try? JSONSerialization.jsonObject(with: self, options: .allowFragments) as! [String : Any] {
            return dic
        } else {
            return nil
        }
    }
}

extension Array {
    
    func split(num:Int) -> [Array] {
        
        if num > self.count {
            return [self]
        }
        
        var splitArr : [Array] = []
        var subArr : [Element] = []
        var index = 0
        
        self.forEach {
            index = index + 1
            if index > num {
                index = 0
                splitArr.append(subArr)
                subArr = []
            }
            
            subArr.append($0)
        }
        
        return splitArr
    }
    
}



