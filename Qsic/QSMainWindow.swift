//
//  QSMainWindow.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/7/9.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation

class QSMainWindow: QSWidget {
    
    init() {
        super.init(startX: 0, startY: 0, width: Int(COLS), height: Int(LINES))
        self.superWidget = self
        setlocale(LC_ALL, "")
        self.window = initscr()
        keypad(stdscr, true)
        noecho()
        raw()
//        start_color()
        refresh()
    }
    
    func endWin() {
        endWin()
    }
    
    func addNavigator(navigator:QSNavigator) {
        self.addSubWidget(widget: navigator.rootWidget!)
        navigator.mainWin = self
    }
}
