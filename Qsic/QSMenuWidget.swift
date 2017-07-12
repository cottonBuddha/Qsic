//
//  QSMenuWidget.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/7/7.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
import Darwin

struct MenuItem {
    var title : String
    var code : Int
    
    init(itemTitle : String, itemCode : Int) {
        self.title = itemTitle
        self.code = itemCode
    }
}

class QSMenuWidget : QSWidget {
    
    var items : [MenuItem]
    
    var currentIndex : Int = 0
    var rowsNum : Int = 9
    var pagesNum : Int
    var currentChoice : MenuItem {
        get {
            return self.items[currentIndex]
        }
    }
    
    var selected : (_ selectedIndex: Int) -> ()
    public init(startX: Int, startY: Int, rowsPerPage: Int, items: [MenuItem], selected: @escaping (_ selectedIndex: Int) -> ()) {
        self.rowsNum = rowsPerPage > 0 ? rowsPerPage : 1
        self.items = items
        self.selected = selected
        let num = self.items.count / rowsPerPage
        self.pagesNum = self.items.count % rowsPerPage == 0 ? num : num + 1
        super.init(startX: startX, startY: startY, width: Int(COLS-2), height: rowsPerPage)
    }
    
    override func drawWidget() {
        guard self.window != nil else {
            return
        }
        
        drawMenu()
        wrefresh(self.window)
    }
    
    func drawMenu() {
        guard self.items.count > 0 else {
            return
        }

        for index in 0..<items.count {
            init_pair(1, Int16(COLOR_CYAN), Int16(COLOR_BLACK))
//            let line = index + 1
            mvwaddstr(self.window, Int32(index), 0, items[index].title)
            mvwchgat(self.window, 0, 0, -1, 2097152, 1, nil)
            
        }
    }
    

    
}


extension QSMenuWidget {
    
    func up() {
        if self.currentIndex > 0 {
            self.currentIndex = self.currentIndex - 1
            mvwchgat(self.window, Int32(self.currentIndex), 0, -1, 2097152, 1, nil)

        }
    }
    
    func down() {
        
    }
    
    func left() {
        
    }
    
    func right() {
        
    }
    
    func enter() {
        
    }
}










