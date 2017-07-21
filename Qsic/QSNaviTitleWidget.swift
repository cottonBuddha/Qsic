//
//  QSNaviTitleWidget.swift
//  Qsic
//
//  Created by 江齐松 on 2017/7/21.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation

class QSNaviTitleWidget: QSWidget {
    
    var titleStack : [String] = []
    
    override init(startX: Int, startY: Int, width: Int, height: Int) {
        super.init(startX: startX, startY: startY, width: width, height: height)
    }
    
    func push(title:String) {
        self.titleStack.append(title)
        self.refresh()
    }
    
    func pop() {
        self.titleStack.removeLast()
        self.refresh()
    }
    
    override func refresh() {
        super.refresh()
        drawWidget()
    }
    
    override func drawWidget() {
        super.drawWidget()
        var naviStr : String = ""
        self.titleStack.forEach {
            naviStr.append($0+". ")
        }
        let index = naviStr.index(naviStr.endIndex, offsetBy: 2)
        let subStr = naviStr.substring(from: index)
        mvwaddstr(self.window, 0, 0, naviStr)
        wrefresh(self.window)
    }
}
