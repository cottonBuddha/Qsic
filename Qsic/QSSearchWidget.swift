//
//  QSSearchWidget.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/8/3.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
class QSSearchWidget: QSWidget {
    
    var inputWidget : QSInputWidget?
    
    convenience init(startX:Int, startY:Int) {
        self.init(startX: startX, startY: startY, width: Int(COLS - startX - 1), height: 1)
    }
    
    override func drawWidget() {
        super.drawWidget()
        self.drawSearchWidget()
        wrefresh(self.window)
    }
    
    func drawSearchWidget() {
        mvwaddstr(self.window, 0, 0, "请输入:")
    }
    
    func getInputContent(completionHandler:@escaping (String)->()) {
        start_color()
        inputWidget = QSInputWidget.init(startX: 8, startY: 0)
        self.addSubWidget(widget: inputWidget!)
        let content = inputWidget?.input()
        completionHandler(content!)
    }
    
//    func input() -> String{
//        curs_set(1)
//        INPUT_TYPE = InputType.Content
//
//        var ic : Int32 = 0
//        var content : String = ""
//        var icStrArr = [String]()
//        var icStrCount : Int = 0
//        repeat {
//            ic = getch()
//            
//            if ic != 127 {
//                
//                let str = String(ic,radix:2)
//                if str.hasPrefix("1110") && str.count == 8 {
//                    icStrArr.append(str.subStr(range: (4,str.characters.count)))
//                    icStrCount = 3
//                    continue
//                }
//                
//                if str.hasPrefix("10") && icStrArr.count > 0 {
//                    if icStrArr.count < icStrCount {
//                        icStrArr.append(str.subStr(range: (2,str.characters.count)))
//                    }
//                    if icStrArr.count == icStrCount {
//                        var icStr : String = ""
//                        icStrArr.forEach {
//                            icStr = icStr.appending($0)
//                        }
//                        ic = Int32(icStr,radix:2)!
//                        icStrArr.removeAll()
//                    } else {
//                        continue
//                    }
//                }
//                
//                let char = Character.init(UnicodeScalar.init(UInt32(ic))!)
//                content.append(char)
//                move(0, 0)
//                addstr(content)
//                
//            } else {
//                if content.count > 0 {
//                    content = content.subStr(range: (0,content.characters.count - 1))
//                }
////                wmove(self.window, 0, 8)
//                move(0, 0)
//                let cStrArr = content.cString(using: String.Encoding.utf8)
//                let str = String.init(cString: cStrArr!)
//                erase()
//                addstr(str)
//            }
//            
//        } while ic != 10
//        
//        curs_set(0)
//        INPUT_TYPE = InputType.Order
//
//        return content
//    }

}
