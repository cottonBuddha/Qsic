//
//  QSMusicController.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/7/12.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
import Darwin

class QSMusicController {
    var mainwin : QSMainWindow = QSMainWindow.init()
    
    private var ch : Character?
    
    private var ic : Int32?
    
    private var menu : QSMenuWidget?
    
    private var menuStack : [QSMenuModle] = []
    
    func start() {
        
        self.menu = self.initHomeMenu()
        self.mainwin.addSubWidget(widget: self.menu!)
        
        self.listenToInstructions()
        
        mainwin.endWin()
    }
    
    func initHomeMenu() -> QSMenuWidget {
        let menuData = [("推荐",0),
                        ("榜单",1),
                        ("歌手",2),
                        ("搜索",3),
                        ("帮助",4)];
        
        var menuItems : [MenuItemModel] = []
        menuData.forEach {
            let item = MenuItemModel.init(title: $0.0, code: $0.1)
            menuItems.append(item)
        }
        
        let mainMenu = QSMenuWidget.init(startX: 3, startY: 3, width: 20,rowsPerPage: 10, items: menuItems) { (item) in
            self.handleHomeSelection(menu: self.menu!, item: item)
            
            
        }
        
        return mainMenu
    }
    
    func handleHomeSelection(menu:QSMenuWidget, item:MenuItemModel) {
        let code = item.code
        switch code {
        case 2:
            API.shared.artists { (artists) in
                let module = QSMenuModle.init(title: "歌手", items: artists, rowsNum: 10, currentRowIndex: 0, currentPageIndex: 0)
                self.push(menuModel: module)
            }
            
        default:
            break
        }
        
    }
    
    
    
    func listenToInstructions() {
        repeat {
            ic = getch()
            self.menu?.handleWithKeyEvent(keyCode: ic!)
        } while ic != KEY_Q_LOW
    }
    
    func push(menuModel:QSMenuModle) {
        self.menuStack.append(menuModel)
        self.menu?.refreshMenu(menuModule: menuModel)
    }
    
    func pop() {
        self.menuStack.removeLast()
        self.menu?.refreshMenu(menuModule: self.menuStack.last!)
    }
}
