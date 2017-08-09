//
//  QSLoginWidget.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/8/2.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
class QSLoginWidget: QSWidget {
    
    var account : String = ""
    var password : String = ""
    
    convenience init(startX:Int, startY:Int) {
        self.init(startX: startX, startY: startY, width: Int(COLS - startX - 1), height: 3)
    }
    
    override func drawWidget() {
        super.drawWidget()
        self.drawLoginWidget()
        wrefresh(self.window)
    }
    
    func drawLoginWidget() {
        mvwaddstr(self.window, 0, 0, "需要登录~")
        mvwaddstr(self.window, 1, 0, "账号:")
        mvwaddstr(self.window, 2, 0, "密码:")
        wmove(self.window, 1, 6)
    }
    
    func getInputContent(completionHandler:(String,String)->()) {
        echo()
        var accountChars : [Int8] = Array<Int8>.init(repeating: 0, count: 30)
        wgetstr(self.window, &accountChars)
        let account = String.init(cString: accountChars)
        
        wmove(self.window, 2, 6)
        var passwordChars : [Int8] = Array<Int8>.init(repeating: 0, count: 30)
        wgetstr(self.window, &passwordChars)
        let password = String.init(cString: passwordChars)
        
        completionHandler(account,password)
        noecho()
    }

    func showSuccess() {
        
    }
    
    func showFaliure() {
        
    }
    
}
