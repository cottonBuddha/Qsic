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
            let item = MenuItemModel.init(title: $0.0)
            menuItems.append(item)
        }
        
        let mainMenu = QSMenuWidget.init(startX: 3, startY: 3, width: 4,rowsPerPage: 9, items: menuItems) { (item) in

            if item.title == "歌手" {
                API.shared.artists { (artists) in
                    let menu = self.initArtistsMenu(artists: artists)
                    self.navigator?.pushTo(menu)
                }
            }

        }
        
        return mainMenu
    }
    
    func initArtistsMenu(artists:[ArtistModle]) -> QSMenuWidget {
        let artistsMenu = QSMenuWidget.init(startX: 3, startY: 3, width: Int(COLS)-6,rowsPerPage: 9, items: artists) { (item) in

            
        }
        
        return artistsMenu
    }
    
    
    
    func listenToInstructions() {
        repeat {
            ic = getch()
            self.navigator?.currentWidget?.handleWithKeyEvent(keyCode: ic!)
        } while ic != KEY_Q_LOW
    }
    
}
