//
//  QSLoginWidget.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/8/2.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
class QSLoginWidget: QSWidget {
    
    convenience init(startX:Int, startY:Int) {
        self.init(startX: startX, startY: startY, width: Int(COLS - startX - 1), height: 3)
    }
    
    override func drawWidget() {
        super.drawWidget()
        self.drawLoginWidget()
        wrefresh(self.window)
    }
    
    func drawLoginWidget() {
        mvwaddstr(self.window, Int32(self.startY), 0, "需要登录：")
        mvwaddstr(self.window, Int32(self.startY + 1), 0, "账号：")
        mvwaddstr(self.window, Int32(self.startY + 2), 0, "密码：")
        
    }
    
    
    
}
