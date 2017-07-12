//
//  QSMusicController.swift
//  Qsic
//
//  Created by 江齐松 on 2017/7/12.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
import Darwin

class QSMusicController {
    var mainwin : QSMainWindow = QSMainWindow.init()
    
    private var ch : Character?
    
    private var ic : Int32?
    
    private var windows : [QSWidget] = []
    
    func start() {
        
        self.initHomeMenu()
        self.listenToInstructions()
        
        mainwin.endWin()
    }
    
    func initHomeMenu() {
        let menuItem0 = MenuItem.init(itemTitle: "推荐", itemCode: 0)
        let menuItem1 = MenuItem.init(itemTitle: "榜单", itemCode: 1)
        let menuItem2 = MenuItem.init(itemTitle: "歌手", itemCode: 2)
        let menuItem3 = MenuItem.init(itemTitle: "搜索", itemCode: 3)
        let menuItem4 = MenuItem.init(itemTitle: "帮助", itemCode: 4)

        let mainMenu = QSMenuWidget.init(startX: 17, startY: 7, width: 4,rowsPerPage: 9, items: [menuItem0,menuItem1,menuItem2,menuItem3,menuItem4]) { (item) in
            
        }
        
        self.windows.append(mainMenu)
        self.mainwin.addSubWidget(widget: mainMenu)
    }
    
    func listenToInstructions() {
        ic = getch()
        ch  = Character(UnicodeScalar(UInt32(ic!))!)
        
        while ch != "q" {
            let widget = self.windows.last as? QSMenuWidget

            switch Int32(ic!) {
                
            case KEY_RIGHT :
                widget?.right()
                
            case KEY_LEFT :
                widget?.left()
                
            case KEY_UP :
                widget?.up()
                
            case KEY_DOWN :
                widget?.down()
                
            case KEY_A_LOW :
                print("m")
                
            default :
                break
            }
            
            ic = getch()
            ch  = Character(UnicodeScalar(UInt32(ic!))!)
            
        }

    }
    
}
