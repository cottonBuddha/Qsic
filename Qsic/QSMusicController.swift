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
    
    private var navtitle : QSNaviTitleWidget?
    private var menu : QSMenuWidget?
    
    private var menuStack : [QSMenuModel] = []
    
    
    
    func start() {
        
        self.menu = self.initHomeMenu()
        self.mainwin.addSubWidget(widget: self.menu!)
        
        self.navtitle = self.initNaviTitle()
        self.mainwin.addSubWidget(widget: self.navtitle!)
        
        self.navtitle?.push(title: self.menu!.title)
        
        self.listenToInstructions()
        
        mainwin.endWin()
    }
    
    func initNaviTitle() -> QSNaviTitleWidget {
        let naviTitle = QSNaviTitleWidget.init(startX: 3, startY: 1, width: 40, height: 1)
        return naviTitle
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
        
        let dataModel = QSMenuModel.init(title: "棉花爱音乐", type:"common", items: menuItems, currentItemCode: 0)
        let mainMenu = QSMenuWidget.init(startX: 3, startY: 3, width: 20, dataModel: dataModel) { (item) in
            self.handleHomeSelection(menu: self.menu!, item: item)
            
            
        }
        
        return mainMenu
    }
    
    func handleHomeSelection(menu:QSMenuWidget, item:MenuItemModel) {
        let code = item.code
        switch code {
        case 2:
            API.shared.artists { (artists) in
                let dataModel = QSMenuModel.init(title: "歌手", type:"common", items: artists, currentItemCode: 0)
                self.push(menuModel: dataModel)
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
    
    func push(menuModel:QSMenuModel) {
        self.menuStack.append(menuModel)
        self.menu?.presentMenuWithModel(menuModel: menuModel)
        self.navtitle?.push(title: menuModel.title)
    }
    
    func pop() {
        self.menuStack.removeLast()
        self.menu?.presentMenuWithModel(menuModel: self.menuStack.last!)
        self.navtitle?.pop()
    }
}
