//
//  QSMusicController.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/7/12.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
import Darwin
import AVFoundation

enum MenuType : Int {
    case Home
    case Artist
    case Song
    case Album
    case SongOrAlbum
    case Ranking
}

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
        
        let dataModel = QSMenuModel.init(title: "棉花爱音乐", type:MenuType.Home, items: menuItems, currentItemCode: 0)
        self.menuStack.append(dataModel)
        let mainMenu = QSMenuWidget.init(startX: 3, startY: 3, width: Int(COLS-6), dataModel: dataModel) { (type,item) in
            if let menuType = MenuType.init(rawValue: type) {
                switch menuType {
                case MenuType.Home:
                    self.handleHomeSelection(item: item)
                case MenuType.Artist:
                    self.handleArtistSelection(item: item as! ArtistModel)
                case MenuType.SongOrAlbum:
                    self.handleSongOrAlbumSelection(item: item as! SongOrAlbumModel)
                case MenuType.Song:
                    self.handleSongSelection(item: item as! SongModel)
                default:
                    break
                }
            }
        }
        
        return mainMenu
    }
    
    func handleHomeSelection(item:MenuItemModel) {
        let code = item.code
        switch code {
        case 1:
            API.shared.rankings(completionHandler: { (rankings) in
                let datamodel = QSMenuModel.init(title: "榜单", type: MenuType.Ranking, items: rankings, currentItemCode: 0)
                self.push(menuModel: datamodel)
            })
        case 2:
            API.shared.artists { (artists) in
                let dataModel = QSMenuModel.init(title: "歌手", type:MenuType.Artist, items: artists, currentItemCode: 0)
                self.push(menuModel: dataModel)
            }
            
        default:
            break
        }
    }
    
    func handleArtistSelection(item:ArtistModel) {
        
        let itemModels = generateSongOrAlbumModels(artistId: item.id)
        let dataModel = QSMenuModel.init(title: "歌曲or专辑", type: MenuType.SongOrAlbum, items: itemModels, currentItemCode: 0)
        self.push(menuModel: dataModel)
    }
    
    func handleSongOrAlbumSelection(item:SongOrAlbumModel) {
        let code = item.code
        switch code {
        case 0:
            API.shared.getSongsOfArtist(artistId: item.artistId) { (models) in
                let dataModel = QSMenuModel.init(title: "歌曲", type:MenuType.Song, items: models, currentItemCode: 0)
                self.push(menuModel: dataModel)
            }
        case 1:
            print("")
        default:
            break
        }
    }
    
    var player : AVAudioPlayer?
    func handleSongSelection(item:SongModel) {
        
        do {
//            player = try AVAudioPlayer(contentsOf: URL.init(string: item.mp3Url!)!)
//            player?.play()
            addstr("链接\(item.mp3Url)")
            addstr("歌曲id\(item.id)")
            refresh()
        } catch {
            
        }
    
    }
    
    func handleRankingSelection(item:RankingModel) {
        
    }
    
    func listenToInstructions() {
        repeat {
            ic = getch()

            self.menu?.handleWithKeyEvent(keyCode: ic!)
            self.handleWithKeyEvent(keyCode: ic!)
        } while ic != KEY_Q_LOW
    }
    
    func push(menuModel:QSMenuModel) {
        self.menuStack.append(menuModel)
        self.menu?.presentMenuWithModel(menuModel: menuModel)
        self.navtitle?.push(title: menuModel.title)
    }
    
    func pop() {
        if self.menuStack.count > 1 {
            self.menuStack.removeLast()
            self.menu?.presentMenuWithModel(menuModel: self.menuStack.last!)
            self.navtitle?.pop()
        }
    }
    
    func handleWithKeyEvent(keyCode:Int32) {
        switch keyCode {
        case KEY_SLASH:
            self.pop()
        default:
            break
        }

    }
}
