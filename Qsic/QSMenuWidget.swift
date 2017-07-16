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
    
    weak var navigator : QSNavigator?
    
    init(itemTitle : String, itemCode : Int) {
        self.title = itemTitle
        self.code = itemCode
    }
}

class QSMenuWidget : QSWidget {
    
    var items : [MenuItem] = []
    
    var currentIndex : Int = 0 {
        didSet {
            if (currentIndex >= 0 && currentIndex < items.count) {
                self.drawWidget()
            } else {
                currentIndex = currentIndex < 0 ? 0 : items.count - 1
            }
        }
    }
    var rowsNum : Int = 9
    var pagesNum : Int
    
    var selected : (_ selectedItem: MenuItem) -> ()
    public init(startX: Int, startY: Int, width: Int, rowsPerPage: Int, items: [MenuItem], selected: @escaping (_ selectedItem: MenuItem) -> ()) {
        self.rowsNum = rowsPerPage > 0 ? rowsPerPage : 1
        self.items = items
        self.selected = selected
        let num = self.items.count / rowsPerPage
        self.pagesNum = self.items.count % rowsPerPage == 0 ? num : num + 1
        super.init(startX: startX, startY: startY, width: width, height: rowsPerPage)
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
            mvwaddstr(self.window, Int32(index), 0, items[index].title)
            mvwchgat(self.window, Int32(self.currentIndex), 0, -1, 2097152, 1, nil)
            
        }
        
//        mvcur(0, 0, 0, 0)
        move(0, 0)
    }
    
    override func handleWithKeyEvent(keyCode:Int32) {
        switch keyCode {
        case KEY_UP:
            self.currentIndex = self.currentIndex - 1
            
        case KEY_DOWN:
            self.currentIndex = self.currentIndex + 1
          
        case 10:
            self.selected(self.items[self.currentIndex])

        default:
            break
        }
    }

}

