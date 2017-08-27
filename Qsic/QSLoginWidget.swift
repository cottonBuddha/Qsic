//
//  QSLoginWidget.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/8/2.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
class QSLoginWidget: QSWidget {
    
    var accountInput: QSInputWidget?
    var passwordInput: QSInputWidget?
    
    var accountLength: Int = 0
    var passwordLength: Int = 0
    
    var isResultShow: Bool = false
    
    convenience init(startX:Int, startY:Int) {
        self.init(startX: startX, startY: startY, width: Int(COLS - startX - 1), height: 3)
    }
    
    override func drawWidget() {
        super.drawWidget()
        self.drawLoginWidget()
        wrefresh(self.window)
    }
    
    private func drawLoginWidget() {
        mvwaddstr(self.window, 0, 0, "需要登录~")
        mvwaddstr(self.window, 1, 0, "账号:")
        mvwaddstr(self.window, 2, 0, "密码:")
    }
    
    func getInputContent(completionHandler:(String,String)->()) {
        
        accountInput = QSInputWidget.init(startX: 6, startY: 1, width: 40, height: 1)
        self.addSubWidget(widget: accountInput!)
        let account = accountInput?.input()
        accountLength = account!.lengthInCurses()
        
        passwordInput = QSInputWidget.init(startX: 6, startY: 2, width: 40, height: 1)
        self.addSubWidget(widget: passwordInput!)
        let password = passwordInput?.input()
        passwordLength = password!.lengthInCurses()
        
        completionHandler(account!,password!)
//        mvaddstr(0, 0, account!)
//        mvaddstr(1, 0, password!)

    }

    private func eraseSelf() {
        mvwaddstr(self.window, 0, 0, 10.space)
        mvwaddstr(self.window, 1, 0, (6 + accountLength).space)
        mvwaddstr(self.window, 2, 0, (6 + passwordLength).space)
        wrefresh(self.window)
    }
    
    func showSuccess() {
        isResultShow = true
        eraseSelf()
        mvwaddstr(self.window, 1, 0, "登录成功")
        wrefresh(self.window)
    }
    
    func showFaliure() {
        isResultShow = true
        eraseSelf()
        mvwaddstr(self.window, 1, 0, "登录失败")
        wrefresh(self.window)
    }
    
    func hide() {
        isResultShow = false
        eraseSelf()
    }
    
}
