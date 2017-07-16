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
    
    var navigator : QSNavigator?
    
    func start() {
        
        self.navigator = QSNavigator.init(rootWidget: self.initHomeMenu())
        self.mainwin.addNavigator(navigator: self.navigator!)
        
//        self.mainwin.addSubWidget(widget: self.initHomeMenu())

//        self.listenToInstructions()
        
//        mainwin.endWin()
    }
    
    func initHomeMenu() -> QSMenuWidget {
        let menuData = [("推荐",0),
                        ("榜单",1),
                        ("歌手",2),
                        ("搜索",3),
                        ("帮助",4)];
        
        var menuItems : [MenuItem] = []
        menuData.forEach {
            let item = MenuItem.init(itemTitle: $0.0, itemCode: $0.1)
            menuItems.append(item)
        }
        
        let mainMenu = QSMenuWidget.init(startX: 3, startY: 3, width: 4,rowsPerPage: 9, items: menuItems) { (item) in
//            self.navigator?.pushTo(self.initSecMenu())
//            self.mainwin.addSubWidget(widget: self.initSecMenu())

        }
        
        return mainMenu
    }
    
    func listenToInstructions() {
//        repeat {
            ic = getch()
            self.navigator?.currentWidget?.handleWithKeyEvent(keyCode: ic!)
//        } while ic != KEY_Q_LOW
    }
    
}
