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
    
    var title : String = ""
    
    var type : String = ""
    
    var dataModel : QSMenuModel! {
        didSet {
            title = dataModel.title
            type = dataModel.type
            currentItemCode = dataModel.currentItemCode
            splitItems = dataModel.items.split(num: dataModel.rowsNum)
        }
    }
    
    var selected : ((_ selectedItem: MenuItemModel) -> ())?
    
    private var currentItemCode : Int = 0 {
        didSet {
            let lastCode = dataModel.items.count - 1
            currentItemCode = currentItemCode > lastCode ? lastCode : (currentItemCode < 0 ? 0 : currentItemCode)
            dataModel.currentItemCode = currentItemCode
            self.currentRowIndex = (dataModel.currentItemCode) % dataModel.rowsNum
            self.currentPageIndex = (dataModel.currentItemCode) / dataModel.rowsNum
        }
    }
    
    private var currentPageIndex : Int = 0
    private var currentRowIndex : Int = 0
    
    private var splitItems : [[MenuItemModel]] = []
    
    public init(startX: Int, startY: Int, width: Int, dataModel: QSMenuModel, selected: ((_ selectedItem: MenuItemModel) -> ())?) {
        self.selected = selected
        super.init(startX: startX, startY: startY, width: width, height: dataModel.rowsNum)
        self.setUpMenu(dataModel: dataModel)
    }
    
    private func setUpMenu(dataModel:QSMenuModel) {
        self.dataModel = dataModel
    }
    
    override func drawWidget() {
        super.drawWidget()
        self.drawMenu()
        wrefresh(self.window)
    }
    
    private func drawMenu() {
        guard self.dataModel.items.count > 0 else {
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
    
    func presentMenuWithModel(menuModel:QSMenuModel) {
        self.setUpMenu(dataModel: menuModel)
        currentPageIndex = 0
        currentRowIndex = 0
        self.drawWidget()
    }
    
    func refreshMenu() {
        self.drawWidget()
    }
    
    override func handleWithKeyEvent(keyCode:Int32) {
        switch keyCode {
        case KEY_UP:
            self.currentItemCode = self.currentItemCode - 1
            self.refreshMenu()
        case KEY_DOWN:
            self.currentItemCode = self.currentItemCode + 1
            self.refreshMenu()
        case 10:
            if self.selected != nil {
                self.selected!(self.dataModel.items[self.currentRowIndex])
            }
            
        default:
            break
        }
    }
    
}

