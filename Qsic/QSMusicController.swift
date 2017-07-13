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
    
    var navigator : QSNavigator?
    
    func start() {
        
        self.navigator = QSNavigator.init(rootWidget: self.initHomeMenu())
        self.mainwin.addNavigator(navigator: self.navigator!)
        self.listenToInstructions()
        
        mainwin.endWin()
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
        
        let mainMenu = QSMenuWidget.init(startX: 0, startY: 0, width: 4,rowsPerPage: 9, items: menuItems) { (item) in
            
//            switch item.code {
//            case 0 :
//                
//            default :
//                break
//            }
            
        }
        
        return mainMenu
    }
    
    func initSecMenu() -> QSMenuWidget {
        let menuData = [("悲伤",0),
                        ("逆流",1),
                        ("成河",2),
                        ("搜索",3),
                        ("帮助",4)];
        
        var menuItems : [MenuItem] = []
        menuData.forEach {
            let item = MenuItem.init(itemTitle: $0.0, itemCode: $0.1)
            menuItems.append(item)
        }
        
        let mainMenu = QSMenuWidget.init(startX: 0, startY: 0, width: 4,rowsPerPage: 9, items: menuItems) { (item) in
            
            //            switch item.code {
            //            case 0 :
            //
            //            default :
            //                break
            //            }
            
        }
        
        return mainMenu
    }
    
    func listenToInstructions() {
        ic = getch()
        ch = Character(UnicodeScalar(UInt32(ic!))!)
        
        while ch != "q" {

            switch Int32(ic!) {
                
            case KEY_RIGHT :
                navigator?.currentWidget?.right()
                
            case KEY_LEFT :
                navigator?.currentWidget?.left()

                
            case KEY_UP :
                navigator?.currentWidget?.up()

                
            case KEY_DOWN :
                navigator?.currentWidget?.down()

                
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
