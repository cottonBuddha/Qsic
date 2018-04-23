//
//  QSNaviTitleWidget.swift
//  Qsic
//
//  Created by 江齐松 on 2017/7/21.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation

class QSNaviTitleWidget: QSWidget {
    
    var titleStack: [String] = []
    var currentSong: String?
    
    override init(startX: Int, startY: Int, width: Int, height: Int) {
        super.init(startX: startX, startY: startY, width: width, height: 2)
    }
    
    public func push(title:String) {
        self.titleStack.append(title)
        self.refreshNaviTitle()
    }
    
    public func pop() {
        self.titleStack.removeLast()
        self.refreshNaviTitle()
    }
    
    public func refreshNaviTitle() {
        drawWidget()
    }
    
    override func drawWidget() {
        super.drawWidget()
        var naviStr : String = ""
        self.titleStack.forEach {
            if $0.lengthInCurses() > 20 {
                naviStr.append("↴" + "\n" + "    " + $0)
            } else {
                naviStr.append("-" + $0)
            }
        }
        if self.titleStack.count < 1 {
            return
        }
        var subStr = naviStr.removeFirstCharacter()
        if currentSong != nil {
            subStr = subStr + "[\(currentSong!)]"
        }
        self.eraseSelf()
        mvwaddstr(self.window, 0, 0, subStr)
        wrefresh(self.window)
    }
}
