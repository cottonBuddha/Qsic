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
    case Song
    case Help
    case Album
    case Artist
    case Search
    case Ranking
    case PlayList
    case SongLists
    case SongOrList
    case SongOrAlbum
    case SongListFirstClass
    case SongListSecondClass
}

public protocol KeyEventProtocol {
    func handleWithKeyEvent(keyEventNoti: Notification)
}

let kNotificationKeyEvent = "NotificationKeyEvent"

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
        
        NotificationCenter.default.addObserver(self, selector: #selector(QSMusicController.songChanged), name:Notification.Name(rawValue: kNotificationSongHasChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(QSMusicController.handleWithKeyEvent(keyEventNoti:)), name:Notification.Name(rawValue: kNotificationKeyEvent), object: nil)

        RunLoop.main.run()
    }
    
    @objc func hahah(keyCode:Notification) {
        print("看一看瞧一瞧：\(String(describing: keyCode.object))")
    }
    
    func initNaviTitle() -> QSNaviTitleWidget {
        let naviTitle = QSNaviTitleWidget.init(startX: 3, startY: 1, width: Int(COLS - 3 - 1), height: 1)
        return naviTitle
    }
    
    func initHomeMenu() -> QSMenuWidget {
        let menuData = [("榜单",0),
                        ("推荐",1),
                        ("歌手",2),
                        ("歌单",3),
                        ("收藏",4),
                        ("搜索",5),
                        ("帮助",6)]
        
        var menuItems : [MenuItemModel] = []
        menuData.forEach {
            let item = MenuItemModel.init(title: $0.0, code: $0.1)
            menuItems.append(item)
        }
        
        let nickName = UserDefaults.standard.value(forKey: UD_USER_NICKNAME) as? String ?? "网易云音乐"
        let dataModel = QSMenuModel.init(title: nickName, type:MenuType.Home, items: menuItems, currentItemCode: 0)
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
                case MenuType.Song, MenuType.PlayList:
                    self.handleSongSelection(item: item as! SongModel)
                case MenuType.Ranking:
                    self.handleRankingSelection(item: item as! RankingModel)
                case MenuType.Album:
                    self.handleAlbumSelection(item: item as! AlbumModel)
                case MenuType.Search:
                    self.handleSearchTypeSelection(item: item as! SearchModel)
                case MenuType.SongListFirstClass:
                    self.handleSongListFirstClassSelection(item: item)
                case MenuType.SongListSecondClass:
                    self.handleSongListSecondClassSelection(item: item)
                case MenuType.SongLists:
                    self.handleSongListsSelection(item: item as! SongListModel)
                case MenuType.SongOrList:
                    self.handleSongOrListSelection(item: item)
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
            API.shared.rankings(completionHandler: { [unowned self] (rankings) in
                let dataModel = QSMenuModel.init(title: "榜单", type: MenuType.Ranking, items: rankings, currentItemCode: 0)
                self.push(menuModel: dataModel)
            })
            
        case 1:
            let menuData = [("推荐歌曲",0),("推荐歌单",1)]
            var menuItems : [MenuItemModel] = []
            menuData.forEach {
                let item = MenuItemModel.init(title: $0.0, code: $0.1)
                menuItems.append(item)
            }
            let dataModel = QSMenuModel.init(title: "推荐", type:MenuType.SongOrList, items: menuItems, currentItemCode: 0)
            self.push(menuModel: dataModel)

        case 2:
            self.menu?.showProgress()
            API.shared.artists { [unowned self] (artists) in
                self.menu?.hideProgress()
                let dataModel = QSMenuModel.init(title: "歌手", type:MenuType.Artist, items: artists, currentItemCode: 0)
                self.push(menuModel: dataModel)
            }

        case 3:
            let models = generateListClassModels()
            let dataModel = QSMenuModel.init(title: "歌单", type: MenuType.SongListFirstClass, items: models, currentItemCode: 0)
            self.push(menuModel: dataModel)
            
        case 4:
            self.menu?.showProgress()
            API.shared.userList(completionHandler: { [unowned self] (models) in
                self.menu?.hideProgress()
                if models.count > 0 {
                    let dataModel = QSMenuModel.init(title: "收藏", type:MenuType.SongLists, items: models, currentItemCode: 0)
                    self.push(menuModel: dataModel)
                } else {
                    self.showHint(with: "提示：未登录，请按\"d\"键进行登录", at: 11)
                }
            })

        case 5:
            self.handleSearchCommandKey()
            
        case 6:
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
            API.shared.getSongsOfArtist(artistId: item.artistId) { [unowned self] (models) in
                let dataModel = QSMenuModel.init(title: "歌曲", type:MenuType.Song, items: models, currentItemCode: 0)
                self.push(menuModel: dataModel)
            }
        case 1:
            API.shared.getAlbumsOfArtist(artistId: item.artistId, completionHandler: { [unowned self] (models) in
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
        if player.currentSongId != nil && player.currentSongId! == player.songList[player.currentIndex].id {
            return
        }
        player.play()
    }
    
    func handleRankingSelection(item:RankingModel) {
        self.menu?.showProgress()
        API.shared.songListDetail(listId: item.id) { [unowned self] (models) in
            self.menu?.hideProgress()
            let dataModel = QSMenuModel.init(title: item.title, type: MenuType.Song, items: models, currentItemCode: 0)
            self.push(menuModel: dataModel)
        }
    }
    
    func handleAlbumSelection(item:AlbumModel) {
        API.shared.getSongsOfAlbum(albumId: item.id) { [unowned self] (models) in
            let dataModel = QSMenuModel.init(title: item.name, type: MenuType.Song, items: models, currentItemCode: 0)
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
        case 3:
            searchType = SearchType.List
        default:
            break
        }
        self.menu?.showProgress()
        API.shared.search(type: searchType, content: item.content) { [unowned self] (type, models) in
            self.menu?.hideProgress()
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
            case .List:
                let menuModel = QSMenuModel.init(title: "歌单", type: MenuType.SongLists, items: models, currentItemCode: 0)
                self.push(menuModel: menuModel)
//                mvaddstr(2, 2, models.first?.title)
            }
        }
    }
    
    func handleSongListFirstClassSelection(item:MenuItemModel) {
        let code = item.code
        var models: [MenuItemModel] = []
        switch code {
        case 0:
            models = generateSongListModels(type: .Languages)
        case 1:
            models = generateSongListModels(type: .Style)
        case 2:
            models = generateSongListModels(type: .Scenario)
        case 3:
            models = generateSongListModels(type: .Emotion)
        case 4:
            models = generateSongListModels(type: .Theme)
        default :
            break
        }
        let dataModel = QSMenuModel.init(title: item.title, type: MenuType.SongListSecondClass, items: models, currentItemCode: 0)
        self.push(menuModel: dataModel)
    }
    
    func handleSongListSecondClassSelection(item:MenuItemModel) {
        self.menu?.showProgress()
        API.shared.songlists(type: item.title) { [unowned self] (models) in
            self.menu?.hideProgress()
            let dataModel = QSMenuModel.init(title: item.title, type: MenuType.SongLists, items: models, currentItemCode: 0)
            self.push(menuModel: dataModel)
        }
    }
    
    func handleSongListsSelection(item:SongListModel) {
        self.menu?.showProgress()
        API.shared.songListDetail(listId: item.id, completionHandler: { [unowned self]
            (songModels) in
            self.menu?.hideProgress()
            let dataModel = QSMenuModel.init(title: item.title, type: MenuType.Song, items: songModels, currentItemCode: 0)
            self.push(menuModel: dataModel)
        })
    }
    
    func handleAddToMyListSelection(item:SongListModel) {

        API.shared.addSongToMyList(tracks: item.idOfTheSongShouldBeAdded, pid: item.id) { [unowned self] (finish) in
            if finish {
                self.showHint(with: "添加完成，请返回↵", at: 14)
            } else {
                self.showHint(with: "添加失败，请返回↵", at: 14)
            }
        }
    }
    
    func handleSongOrListSelection(item:MenuItemModel) {
        let code = item.code
        switch code {
        case 0:
            self.menu?.showProgress()
            API.shared.recommendSongs(completionHandler: { [unowned self] (models) in
                self.menu?.hideProgress()
                if models.count > 0 {
                    let dataModel = QSMenuModel.init(title: "推荐", type:MenuType.Song, items: models, currentItemCode: 0)
                    self.push(menuModel: dataModel)
                } else {
                    self.showHint(with: "提示：未登录，请返回首页按\"d\"键进行登录", at: 11)
                }
            })
        case 1:
            self.menu?.showProgress()
            API.shared.recommendPlayList(completionHandler: { [unowned self] (models) in
                self.menu?.hideProgress()
                if models.count > 0 {
                    let dataModel = QSMenuModel.init(title: "推荐", type:MenuType.SongLists, items: models, currentItemCode: 0)
                    self.push(menuModel: dataModel)
                } else {
                    self.showHint(with: "提示：未登录，请返回首页按\"d\"键进行登录", at: 11)
                }
            })
        default:
            break
        }
    }
    
    func handleLoginCommandKey() {
        guard menuStack.last?.type == MenuType.Home.rawValue else {
            beep()
            return
        }
        
        if player.isPlaying {
            player.dancer?.pause()
        }

        let startY = menuStack.last?.type == MenuType.Home.rawValue ? 11 : 14
        self.loginWidget = QSLoginWidget.init(startX: 3, startY: startY)
        self.mainwin.addSubWidget(widget: self.loginWidget!)
        self.loginWidget?.getInputContent(completionHandler: { (account, password) in

            API.shared.login(account: account, password: password, completionHandler: { [unowned self] (accountNameAndId) in
                if self.player.isPlaying {
                    self.player.dancer?.load()
                }
                self.removeLoginWidget()
                if accountNameAndId.0 != "" {
                    self.navtitle?.titleStack.removeFirst()
                    self.navtitle?.titleStack.insert(accountNameAndId.0, at: 0)
                    self.navtitle?.drawWidget()
                    UserDefaults.standard.set(accountNameAndId.0, forKey: UD_USER_NICKNAME)
                    UserDefaults.standard.set(accountNameAndId.1, forKey: UD_USER_ID)

                    self.showHint(with: "登录成功！", at: 11)
                } else {
                    self.showHint(with: "登录失败！", at: 11)
                }
            })
        })
    }
    
    func handleSearchCommandKey() {
        guard menuStack.last?.type == MenuType.Home.rawValue else {
            beep()
            return
        }
        
        if player.isPlaying {
            player.dancer?.pause()
        }
        
        let startY = 11
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
        if player.songList.count > 0 && menuStack.last?.type != MenuType.PlayList.rawValue{
            let menuModel = QSMenuModel.init(title: "播放列表", type: MenuType.PlayList, items: player.songList, currentItemCode: player.currentIndex)
            self.push(menuModel: menuModel)
        } else {
            beep()
        }
    }
    
    func handleAddToMyListCommandKey() {
        let lastMenu = menuStack.last
        guard lastMenu?.type == MenuType.Song.rawValue else {
            beep()
            return
        }
        let currentItem = lastMenu?.items[lastMenu!.currentItemCode] as! SongModel
        API.shared.like(id: currentItem.id) { [unowned self] (finish) in
            if finish {
                self.showHint(with: "已添加至喜欢↵", at: 14)
            } else {
                self.showHint(with: "添加失败↵", at: 14)
            }
        }
    }
    
    @objc func listenToInstructions() {
        var ic : Int32 = 0
        repeat {
            ic = getch()
            if isHintOn && ic != CMD_PLAYMODE_SINGLE && ic != CMD_PLAYMODE_ORDER && ic != CMD_PLAYMODE_SHUFFLE{
                self.hideHint()
                continue
            }
//            mvwaddstr(self.mainwin.window, 2, 2, "\(ic)")
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationKeyEvent), object: ic)
            }
//            print(ic)
//            self.menu?.handleWithKeyEvent(keyEventNoti: ic)
//            self.handleWithKeyEvent(keyCode: ic)
//            self.player.handleWithKeyEvent(keyEventNoti: ic)
        } while (ic != CMD_QUIT && ic != CMD_QUIT_LOGOUT)
        
        curs_set(1)
        if ic == CMD_QUIT_LOGOUT {
            API.shared.clearLoginCookie {
                UserDefaults.standard.removeObject(forKey: UD_USER_NICKNAME)
                UserDefaults.standard.removeObject(forKey: UD_USER_ID)
            }
        }
        
        DispatchQueue.main.async {
            self.menu?.eraseSelf()
            self.navtitle?.eraseSelf()
            self.player.dancer?.eraseSelf()
            self.mainwin.end()
            NotificationCenter.default.removeObserver(self)
            exit(0)
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
    
    @objc func handleWithKeyEvent(keyEventNoti: Notification) {
        if menu?.progress != nil, menu!.progress!.isLoading {
            return
        }
        let keyCode = keyEventNoti.object as! Int32
        switch keyCode {
        case CMD_BACK.0, CMD_BACK.1:
            self.pop()
        case CMD_SEARCH:
            self.handleSearchCommandKey()
        case CMD_LOGIN:
            self.handleLoginCommandKey()
        case CMD_PLAY_LIST:
            self.handlePlayListCommandKey()
        case CMD_GITHUB:
            let task = Process.init()
            task.launchPath = "/bin/bash"
            task.arguments = ["-c","open https://github.com/cottonBuddha/Qsic"]
            task.launch()
        case CMD_PLAYMODE_SINGLE:
            let startY = menuStack.last?.type == MenuType.Home.rawValue ? 11 : 14
            showHint(with: "设置为:单曲循环↵", at: startY)
            beep()
        case CMD_PLAYMODE_ORDER:
            let startY = menuStack.last?.type == MenuType.Home.rawValue ? 11 : 14
            showHint(with: "设置为:顺序播放↵", at: startY)
            beep()
        case CMD_PLAYMODE_SHUFFLE:
            let startY = menuStack.last?.type == MenuType.Home.rawValue ? 11 : 14
            showHint(with: "设置为:随机播放↵", at: startY)
            beep()
        case CMD_ADD_LIKE:
            self.handleAddToMyListCommandKey()
        default:
            break
        }
    }
    
    private var contentLength = 0
    private var lineNum = 0
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
        move(0, 0)
        refresh()
    }
    
    func removeLoginWidget() {
        guard loginWidget != nil else { return }
        loginWidget?.hide()
        loginWidget = nil
    }
    
    @objc func songChanged() {
        navtitle?.currentSong = player.songList[player.currentIndex].title
        navtitle?.drawWidget()
    }
    
}
