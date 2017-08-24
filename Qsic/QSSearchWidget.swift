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

        inputWidget = QSInputWidget.init(startX: 8, startY: 0, width: 20, height: 1)
        self.addSubWidget(widget: inputWidget!)
        let content = inputWidget?.input()
        completionHandler(content!)
    }

}