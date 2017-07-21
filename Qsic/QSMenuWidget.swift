//
//  QSMenuWidget.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/7/7.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
import Darwin

class QSMenuWidget : QSWidget {
    
    var title : String = "棉花爱音乐"
    
    var items : [MenuItemModel] = []
    
    private var splitItems : [[MenuItemModel]] = []
    
    var rowsNumPerPage : Int = 10
    
    var currentRowIndex : Int = 0 {
        didSet {
            if (currentRowIndex >= 0 && currentRowIndex < items.count) {
                self.drawWidget()
            } else {
                currentRowIndex = currentRowIndex < 0 ? 0 : items.count - 1
            }
        }
    }
    
    var currentPageIndex : Int = 0 {
        didSet {
            if (currentPageIndex >= 0 && currentRowIndex < splitItems.count) {
                
                self.drawWidget()
            } else {
                currentPageIndex = currentPageIndex < 0 ? 0 : splitItems.count - 1
            }
        }
    }
    
    
    var selected : (_ selectedItem: MenuItemModel) -> ()
    
    public init(startX: Int, startY: Int, width: Int, rowsPerPage: Int, items: [MenuItemModel], selected: @escaping (_ selectedItem: MenuItemModel) -> ()) {
        self.selected = selected
        super.init(startX: startX, startY: startY, width: width, height: rowsPerPage)
        self.setUpMenu(items: items, rowsPerPage: rowsPerPage, currentPageIndex: 0, currentRowIndex: 0)
    }
    
    private func setUpMenu(items: [MenuItemModel], rowsPerPage: Int, currentPageIndex:Int, currentRowIndex:Int) {
        self.items = items
        self.splitItems = items.split(num: self.rowsNumPerPage)
        self.rowsNumPerPage = rowsPerPage < 0 ? 0 : rowsPerPage
        self.currentPageIndex = currentPageIndex
        self.currentRowIndex = currentRowIndex
    }
    
    override func drawWidget() {
        guard self.window != nil else {
            return
        }
        
        self.drawMenu()
        wrefresh(self.window)
    }
    
    private func drawMenu() {
        guard self.items.count > 0 else {
            return
        }
        wclear(self.window)
        for index in 0..<self.splitItems[self.currentPageIndex].count {
            init_pair(1, Int16(COLOR_CYAN), Int16(COLOR_BLACK))
            mvwaddstr(self.window, Int32(index), 0, splitItems[self.currentPageIndex][index].title)
            mvwchgat(self.window, Int32(self.currentRowIndex), 0, -1, 2097152, 1, nil)
            
        }
        
        move(0, 0)
    }
    
    func refreshMenu(menuModule:QSMenuModle) {
        
        self.setUpMenu(items: menuModule.items, rowsPerPage: menuModule.rowsNum, currentPageIndex: currentPageIndex, currentRowIndex: currentRowIndex)
        self.drawWidget()
    }
    
    override func handleWithKeyEvent(keyCode:Int32) {
        switch keyCode {
        case KEY_UP:
            if currentRowIndex > 0 {
                self.currentRowIndex = self.currentRowIndex - 1
            } else {
                let rowIndex = self.currentPageIndex == 0 ? 0 : self.rowsNumPerPage - 1
                self.currentPageIndex = self.currentPageIndex - 1
                self.currentRowIndex = rowIndex
            }
            
        case KEY_DOWN:
            if self.currentRowIndex < self.splitItems[self.currentPageIndex].count - 1 {
                self.currentRowIndex = self.currentRowIndex + 1
            } else {
                let rowIndex = self.currentPageIndex == self.splitItems.count - 1 ? self.splitItems[self.currentPageIndex].count - 2 : 0
                
                self.currentPageIndex = self.currentPageIndex + 1
                self.currentRowIndex = rowIndex
            }
            
        case 10:
            self.selected(self.items[self.currentRowIndex])
            
        default:
            break
        }
    }
    
}

