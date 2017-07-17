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
