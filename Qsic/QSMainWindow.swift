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
        cbreak()
//        use_default_colors()
//        start_color()
//        init_pair(1,Int16(COLOR_WHITE),Int16(COLOR_BLUE));
//        init_pair(2,Int16(COLOR_BLUE),Int16(COLOR_WHITE));
//        init_pair(3,Int16(COLOR_RED),Int16(COLOR_CYAN));
//        bkgd(3)
        curs_set(0)
        refresh()
    }
    
    func end() {
        endwin()
    }
    
}
