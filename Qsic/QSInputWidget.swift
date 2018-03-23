//
//  QSInputWidget.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/8/7.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
class QSInputWidget: QSWidget {
    
    override init(startX: Int, startY: Int, width: Int, height: Int) {
        super.init(startX: startX, startY: startY, width: width, height: height)
    }
    
    func input() -> String{
        wmove(self.window, 0, 0)
        curs_set(1)
        
        var ic : Int32 = 0
        
        var content : String = ""
        var condition = true
        var icStrArr = [String]()
        var icStrCount : Int = 0
        repeat {
            curs_set(1)
            ic = wgetch(self.window)
            wmove(self.window, 0, 0)
            condition = ic != CMD_ENTER
            if ic != 127 {
                if ic == CMD_ENTER { break }
                let str = String(ic,radix:2)
                if str.hasPrefix("1110") && str.count == 8 {
                    icStrArr.append(str.subStr(range: (4,str.count)))
                    icStrCount = 3
                    continue
                }
                
                if str.hasPrefix("10") && icStrArr.count > 0 {
                    if icStrArr.count < icStrCount {
                        icStrArr.append(str.subStr(range: (2,str.count)))
                    }
                    if icStrArr.count == icStrCount {
                        var icStr : String = ""
                        icStrArr.forEach {
                            icStr = icStr.appending($0)
                        }
                        ic = Int32(icStr,radix:2)!
                        icStrArr.removeAll()
                    } else {
                        continue
                    }
                }
                
                let char = Character.init(UnicodeScalar.init(UInt32(ic))!)
                content.append(char)
                wmove(self.window, 0, 0)
                waddstr(self.window, content)
                
            } else {
                if content.count > 0 {
                    content = content.subStr(range: (0,content.count - 1))
                }
                let cStrArr = content.cString(using: String.Encoding.utf8)
                let str = String.init(cString: cStrArr!)
                werase(self.window)
                wmove(self.window, 0, 0)
                waddstr(self.window, str)
                
            }
            
        } while condition
        
        curs_set(0)
        
        return content
    }
    
}

