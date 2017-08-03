//
//  QSSearchWidget.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/8/3.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
class QSSearchWidget: QSWidget {
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
        move(Int32(self.startY), Int32(self.startX + 8))
    }
    
    func getInputContent(completionHandler:(String)->()) {
        echo()
        var m : [Int8] = Array<Int8>.init(repeating: 0, count: 30);
        wgetstr(self.window, &m)
//        move(0,0)
//        addstr("东西看这里")
        let str = String.init(cString: m)
//        addstr(str)
        completionHandler(str)
        noecho()
    }

}
