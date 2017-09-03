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
    
    func push(title:String) {
        self.titleStack.append(title)
        self.refreshNaviTitle()
    }
    
    func pop() {
        self.titleStack.removeLast()
        self.refreshNaviTitle()
    }
    
    func refreshNaviTitle() {

        drawWidget()
    }
    
    override func drawWidget() {
        super.drawWidget()
        var naviStr : String = ""
        self.titleStack.forEach {
            naviStr.append($0+"-")
        }
        if self.titleStack.count < 1 {
            return
        }
        let index = naviStr.index(naviStr.endIndex, offsetBy: -1)
        var subStr = naviStr.substring(to: index)
        if currentSong != nil {
            subStr = subStr + "[\(currentSong!)]"
        }
        self.eraseSelf()
        mvwaddstr(self.window, 0, 0, subStr)
        wrefresh(self.window)
    }
    
}

