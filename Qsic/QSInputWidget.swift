//
//  QSInputWidget.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/8/7.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
class QSInputWidget: QSWidget,KeyEventProtocol {
    
    var histInputArr: [String]? = ["心愿便利贴", "笑嘻嘻的少年"]
    var histIndex = 0

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
                
                if str.hasPrefix("110") && str.count == 8 {
                    icStrArr.append(str.subStr(range: (3,str.count)))
                    icStrCount = 2
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
                print("看看是什么")
                print(ic)
                print(char)

//                if histInputArr != nil && histInputArr!.count > 0 {
                    if content == "^[[A" {

//                        icStrCount = content.lengthInCurses()
//                        continue
                    }

                    if content == "^[[B" {
                        content = histInputArr![histIndex]
                        histIndex = histIndex - 1 < 0 ? histInputArr!.count - 1 : histIndex - 1
//                        icStrCount = content.lengthInCurses()
//                        continue
                    }
//                }
//                wmove(self.window, 0, 0)
//                waddstr(self.window, content)
                
                
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
    
    private func updateContent(content: String) {
        werase(self.window)
        wmove(self.window, 0, 0)
        waddstr(self.window, content)
    }
    
    @objc func handleWithKeyEvent(keyEventNoti: Notification) {
        let keyCode = keyEventNoti.object as! Int32
        switch keyCode {
//        case CMD_BACK.0, CMD_BACK.1:
            
        case CMD_UP:
            let content = histInputArr![histIndex]
            updateContent(content: content)
            histIndex = histIndex + 1 > histInputArr!.count - 1 ? 0 : histIndex + 1

        case CMD_DOWN:
            let content = histInputArr![histIndex]
            updateContent(content: content)
            histIndex = histIndex - 1 < 0 ? histInputArr!.count - 1 : histIndex - 1
            
        case CMD_LEFT:
            print("hahaha")
        case CMD_RIGHT:
            print("hahaha")

        default:
            break
        }
    }
    
}
