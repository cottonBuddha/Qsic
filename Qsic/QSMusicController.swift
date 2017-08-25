//
//  QSMusicController.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/7/12.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
import Darwin

enum MenuType: Int {
    case Home
    case Artist
    case Song
    case Album
    case SongOrAlbum
    case Ranking
    case Search
    case Help
}

public protocol KeyEventProtocol {
    func handleWithKeyEvent(keyCode:Int32)
}

class QSMusicController {
    
    private var navtitle : QSNaviTitleWidget?
    private var menu : QSMenuWidget?
    private var menuStack : [QSMenuModel] = []
    private var getchThread : Thread?
    private var searchBar : QSSearchWidget?
    private var loginWidget : QSLoginWidget?
    private var player : QSPlayer = QSPlayer.shared
    private var isHintOn: Bool = false
    
    var mainwin : QSMainWindow = QSMainWindow.init()

    func start() {
        
        self.menu = self.initHomeMenu()
        self.mainwin.addSubWidget(widget: self.menu!)
        
        self.navtitle = self.initNaviTitle()
        self.mainwin.addSubWidget(widget: self.navtitle!)
        
        self.navtitle?.push(title: self.menu!.title)
        
        self.getchThread = Thread.init(target: self, selector: #selector(QSMusicController.listenToInstructions), object: nil)
        self.getchThread?.start()
        
        self.mainwin.addSubWidget(widget: player.dancer!)
        RunLoop.main.run()
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
                        ("帮助",4)]
        
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
                case MenuType.Ranking:
                    self.handleRankingSelection(item: item as! RankingModel)
                case MenuType.Album:
                    self.handleAlbumSelection(item: item as! AlbumModel)
                case MenuType.Search:
                    self.handleSearchTypeSelection(item: item as! SearchModel)
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
        case 0:
            self.menu?.showProgress()
            API.shared.recommendPlaylist(completionHandler: { [unowned self] (models) in
                self.menu?.hideProgress()
                if models.count > 0 {
                    let dataModel = QSMenuModel.init(title: "推荐", type:MenuType.Song, items: models, currentItemCode: 0)
                    self.push(menuModel: dataModel)
                } else {
                    self.showHint(with: "提示：未登录，请按\"d\"键进行登录", at: 10)
                }
                
            })
        case 1:
            API.shared.rankings(completionHandler: { (rankings) in
                let datamodel = QSMenuModel.init(title: "榜单", type: MenuType.Ranking, items: rankings, currentItemCode: 0)
                self.push(menuModel: datamodel)
            })
        case 2:
            self.menu?.showProgress()
            API.shared.artists { (artists) in
                self.menu?.hideProgress()
                let dataModel = QSMenuModel.init(title: "歌手", type:MenuType.Artist, items: artists, currentItemCode: 0)
                self.push(menuModel: dataModel)
            }
        case 3:
            self.handleSearchCommandKey()
        case 4:
            let models = generateHelpModels()
            let menuModel = QSMenuModel.init(title: "帮助", type: MenuType.Help, items: models, currentItemCode: 0)
            self.push(menuModel: menuModel)
            
        default:
            break
        }
    }
    
    func handleArtistSelection(item:ArtistModel) {
        
        let itemModels = generateSongOrAlbumModels(artistId: item.id)
        let dataModel = QSMenuModel.init(title: item.name, type: MenuType.SongOrAlbum, items: itemModels, currentItemCode: 0)
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
            API.shared.getAlbumsOfArtist(artistId: item.artistId, completionHandler: { (models) in
                let dataModel = QSMenuModel.init(title: "专辑", type: MenuType.Album, items: models, currentItemCode: 0)
                self.push(menuModel: dataModel)
            })
        default:
            break
        }
    }
    
    func handleSongSelection(item:SongModel) {
        player.songList = self.menuStack.last?.items as! [SongModel]
        player.currentIndex = item.code
        player.play()
    }
    
    func handleRankingSelection(item:RankingModel) {
        self.menu?.showProgress()
        API.shared.songDetail(rankingId: item.id) { (models) in
            self.menu?.hideProgress()
            let dataModel = QSMenuModel.init(title: item.title, type: MenuType.Song, items: models, currentItemCode: 0)
            self.push(menuModel: dataModel)
        }
    }
    
    func handleAlbumSelection(item:AlbumModel) {
        API.shared.getSongsOfAlbum(albumId: item.id) { (models) in
            let dataModel = QSMenuModel.init(title: "歌曲", type: MenuType.Song, items: models, currentItemCode: 0)
            self.push(menuModel: dataModel)
        }
    }
    
    func handleSearchTypeSelection(item:SearchModel) {
        var searchType = SearchType.Song
        switch item.code {
        case 0:
            searchType = SearchType.Song
        case 1:
            searchType = SearchType.Artist
        case 2:
            searchType = SearchType.Album
        default:
            break
        }
        API.shared.search(type: searchType, content: item.content) { (type, models) in
            switch type {
            case .Song:
                let menuModel = QSMenuModel.init(title: "歌曲", type:MenuType.Song, items: models, currentItemCode: 0)
                self.push(menuModel: menuModel)
            case .Artist:
                let menuModel = QSMenuModel.init(title: "歌手", type: MenuType.Artist, items: models, currentItemCode: 0)
                self.push(menuModel: menuModel)
            case .Album:
                let menuModel = QSMenuModel.init(title: "专辑", type: MenuType.Album, items: models, currentItemCode: 0)
                self.push(menuModel: menuModel)

            }
        }
    }
    
    func handleLoginCommandKey() {
        if player.isPlaying {
            player.dancer?.pause()
        }
        let startY = menuStack.last?.type == MenuType.Home.rawValue ? 9 : 14
        self.loginWidget = QSLoginWidget.init(startX: 3, startY: startY)
        self.mainwin.addSubWidget(widget: self.loginWidget!)
        self.loginWidget?.getInputContent(completionHandler: { (account, password) in
            API.shared.login(account: account, password: password, completionHandler: { (accountName) in
                if self.player.isPlaying {
                    self.player.dancer?.load()
                }
                if accountName != "" {
                    self.navtitle?.titleStack.removeFirst()
                    self.navtitle?.titleStack.insert(accountName, at: 0)
                    self.navtitle?.drawWidget()
                    self.loginWidget?.showSuccess()
                } else {
                    self.loginWidget?.showFaliure()
                }
            })
        })
    }
    
    func handleSearchCommandKey() {
        
        if player.isPlaying {
            player.dancer?.pause()
        }
        
        let startY = menuStack.last?.type == MenuType.Home.rawValue ? 9 : 14
        searchBar = QSSearchWidget.init(startX: 3, startY: startY)
        mainwin.addSubWidget(widget: searchBar!)
        searchBar?.getInputContent(completionHandler: {[unowned self] (content) in
            if self.player.isPlaying {
                self.player.dancer?.load()
            }
            self.searchBar?.eraseSelf()
            self.mainwin.removeSubWidget(widget: self.searchBar!)
            let models = generateSearchTypeModels(content: content)
            let menuModel = QSMenuModel.init(title: "搜索", type: MenuType.Search, items: models, currentItemCode: 0)
            self.push(menuModel: menuModel)
        })
    }
    
    func handlePlayListCommandKey() {
        if player.songList.count > 0 {
            let menuModel = QSMenuModel.init(title: "播放列表", type: MenuType.Song, items: player.songList, currentItemCode: player.currentIndex)
            self.push(menuModel: menuModel)
        } else {
            beep()
        }
    }
    
    @objc func listenToInstructions() {
        var ic : Int32 = 0
        repeat {
            ic = getch()
            
            self.menu?.handleWithKeyEvent(keyCode: ic)
            self.handleWithKeyEvent(keyCode: ic)
            self.player.handleWithKeyEvent(keyCode: ic)
        } while ic != KEY_Q_LOW
        curs_set(1)
        menu?.eraseMenu()
        navtitle?.erase()
        DispatchQueue.main.async {
            self.mainwin.endWin()
        }
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
        
        if isHintOn {
            self.hideHint()
        }
        
        if loginWidget != nil, loginWidget!.isResultShow {
            loginWidget!.hide()
            self.removeLoginWidget()
        }
        
        switch keyCode {
        case KEY_SLASH_EN, KEY_SLASH_ZH:
            self.pop()
        case KEY_S_LOW:
            self.handleSearchCommandKey()
        case KEY_D_LOW:
            self.handleLoginCommandKey()
        case KEY_F_LOW:
            self.handlePlayListCommandKey()
        case KEY_G_LOW:
//            system("open https://github.com/cottonBuddha/Qsic")
            let task = Process.init()
            task.launchPath = "/bin/bash"
            task.arguments = ["-c","open https://github.com/cottonBuddha/Qsic"]
            task.launch()
        default:
            break
        }
    }
    
    var contentLength = 0
    var lineNum = 0
    func showHint(with content: String, at lineNum: Int) {
        isHintOn = true
        contentLength = content.lengthInCurses()
        self.lineNum = lineNum
        mvwaddstr(self.mainwin.window, Int32(lineNum), 3, content)
        refresh()
    }
    
    func hideHint() {
        isHintOn = false
        mvwaddstr(self.mainwin.window, Int32(lineNum), 3, contentLength.space)
        contentLength = 0
        refresh()
    }
    
    func removeLoginWidget() {
        guard loginWidget != nil else { return }
        loginWidget?.hide()
        loginWidget = nil
    }
    
}
