//
//  models.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/7/19.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation

public class MenuItemModel {
    var title : String = ""
    var code : Int = 0
    
    public init(title:String, code:Int) {
        self.title = title
        self.code = code
    }
}

public class QSMenuModel {
    var id : String = "0"
    var title : String = ""
    var type : Int = 0
    var items : [MenuItemModel] = []
    var rowsNum : Int = 10
    var currentItemCode : Int = 0 {
        didSet {
            let lastCode = self.items.count - 1
            currentItemCode = currentItemCode > lastCode ? lastCode : (currentItemCode < 0 ? 0 : currentItemCode)
        }
    }
    
    init(title:String, type:MenuType, items:[MenuItemModel], rowsNum:Int = 10, currentItemCode:Int) {
        
        self.title = title
        self.type = type.rawValue
        self.items = items
        self.rowsNum = rowsNum
        let lastCode = items.count - 1
        self.currentItemCode = currentItemCode > lastCode ? lastCode : (currentItemCode < 0 ? 0 : currentItemCode)
    }
}

//MARK:歌手列表
public class ArtistModel: MenuItemModel {
    var name : String = ""
    var id :String = ""
    
    init(itemDic:Dictionary<String, Any>, code:Int) {
        self.name = itemDic["name"] as! String
        self.id = (itemDic["id"] as! NSNumber).stringValue
        super.init(title: self.name,code: code)
    }
}

public func generateArtistModles(data:Data) -> [ArtistModel] {
    if let dic = data.jsonObject() as? NSDictionary {
        var artists : [ArtistModel] = []
        var jsonArr : NSArray = []
        
        if let arr = dic["artists"] as? NSArray {
            jsonArr = arr
        } else if let arr = (dic["result"] as? NSDictionary)?["artists"] as? NSArray {
            jsonArr = arr
        }

        var code = 0
        jsonArr.forEach {
            let artist = ArtistModel.init(itemDic: $0 as! Dictionary<String, Any>, code: code)
            artists.append(artist)
            code = code + 1
        }
        return artists
    }
    
    return []
}

//歌曲列表
public class SongModel:MenuItemModel {
    var name : String = ""
    var id : String = ""
    var mp3Url : String?
    var quality : String = ""
    var artist : String = ""
    var album : String = ""
    
    init(itemDic:Dictionary<String, Any>, code:Int) {
    
        self.name = itemDic["name"] as! String
        self.id = (itemDic["id"] as! NSNumber).stringValue//dfsId是什么
        self.mp3Url = itemDic["mp3Url"] as? String
        self.quality = itemDic["quality"] as! String
        self.artist = itemDic["artist"] as! String
        self.album = itemDic["album"] as! String
        
        super.init(title: self.name, code: code)
    }
}

public func generateSongModels(data:Data) -> [SongModel] {
    var songArr : NSArray = []
    var songModels : [SongModel] = []

    if let dic = data.jsonObject() as? NSDictionary {
        if let arr = dic["hotSongs"] as? NSArray{
            songArr = arr 
        } else if let arr = dic["songs"] as? NSArray {
            songArr = arr 
        } else if let albumDic = dic["album"] as? [String:Any] {
            songArr = albumDic["songs"] as! NSArray
        } else if let arr = dic["recommend"] as? NSArray {
            songArr = arr
        } else if let arr = (dic["playlist"] as? NSDictionary)?["songs"] as? NSArray {
            songArr = arr
        } else if let arr = (dic["playlist"] as? NSDictionary)?["tracks"] as? NSArray {
            songArr = arr
        }
    }
    
    var code = 0
    songArr.forEach({ (item) in
        var itemDic : [String : Any] = [:]
        let item = item as! [String : Any]
        itemDic["name"] = item["name"]
        itemDic["id"] = item["id"]
        itemDic["mp3Url"] = item["mp3Url"]
        itemDic["quality"] = "hMusic"
        var artistStr = ""
        var albumName = ""
        if let albumDic = item["album"] as? [String:Any] {
            
            if let artists = albumDic["artists"] as? [Any] {
                artists.forEach {
                    let artDic = $0 as! [String:Any]
                    artistStr.append(artDic["name"] as! String)
                    artistStr.append(" ")
                }
                albumName = albumDic["name"] as! String
            }
        }
        
        itemDic["artist"] = artistStr
        itemDic["album"] = albumName
        
        let song = SongModel.init(itemDic: itemDic, code: code)
        songModels.append(song)
        code = code + 1
    })
    
    return songModels
}

//专辑列表
public class AlbumModel:MenuItemModel {
    var name : String = ""
    var id : String = ""
    var artist : String = ""
    
    init(name:String, id:String, artist:String, code:Int) {
        self.name = name
        self.id = id
        self.artist = artist
        super.init(title: name, code: code)
    }
}

public func generateAlbumModels(data:Data) -> [AlbumModel] {
    if let dic = data.jsonObject() as? NSDictionary {
        var albums : [AlbumModel] = []
        var jsonArr : NSArray = []
        if let arr = dic["hotAlbums"] as? NSArray{
            jsonArr = arr
        } else if let arr = (dic["result"] as? NSDictionary)?["albums"] as? NSArray{
            jsonArr = arr
        }
        
        var code = 0
        jsonArr.forEach {
            let albumDic = $0 as! [String:Any]
            let name = albumDic["name"] as! String
            let id = (albumDic["id"] as! NSNumber).stringValue
            var artists : String = ""
            if let arr = dic["artists"] as? NSArray{
                var code = 0
                arr.forEach {
                    let artistDic = $0 as! [String:Any]
                    artists.append(artistDic["name"] as! String)
                    code = code + 1
                }
            }
            let album = AlbumModel.init(name: name, id: id, artist: artists, code: code)
            albums.append(album)
            code = code + 1
        }
        
        return albums
    }
    
    return []
}


//歌曲或专辑选择列表
public class SongOrAlbumModel:MenuItemModel {
    var name : String = ""
    var artistId : String = ""
    
    init(name:String, artistId:String, code:Int) {
        self.name = name
        self.artistId = artistId
        super.init(title: self.name, code: code)
    }
}

public func generateSongOrAlbumModels(artistId:String) -> [SongOrAlbumModel] {
    let titleArr = [("热门单曲",0),("所有专辑",1)]
    var itemArr : [SongOrAlbumModel] = []
    titleArr.forEach {
        let item = SongOrAlbumModel.init(name: $0.0, artistId: artistId, code: $0.1)
        itemArr.append(item)
    }
    return itemArr
}

//歌单
public class SongListModel: MenuItemModel {
    var name: String = ""
    var id: String = ""
    var creator: String = ""
    var idOfTheSongShouldBeAdded: String = ""

    init(name:String, id:String, creator:String, code:Int) {
        self.name = name
        self.id = id
        self.creator = creator
        super.init(title: name, code: code)
    }
}

public func generateSongListsModels(data: Data) -> [SongListModel] {
    var lists: [SongListModel] = []

    let dic = data.jsonObject() as? NSDictionary
    guard dic != nil else { return lists }
    
    var playlists: NSArray = []
    if let result = dic!["result"] as? NSDictionary {
        if let pl = result["playlists"] as? NSArray {
            playlists = pl
        }
    } else if let pl = dic!["playlists"] as? NSArray {
        playlists = pl
    } else if let pl = dic!["playlist"] as? NSArray {
        playlists = pl
    } else if let pl = dic!["recommend"] as? NSArray {
        playlists = pl
    }
    
    var code = 0
    playlists.forEach({ (element) in
        let element = element as! NSDictionary
        let name = element["name"] as! String
        let id = element["id"] as! NSNumber
        var creatorName = ""
        if let creatorInfo = element["creator"] as? NSDictionary {
            creatorName = creatorInfo["nickname"] as! String
        }
        let model = SongListModel.init(name: name, id: id.stringValue, creator: creatorName, code: code)
        code = code + 1
        lists.append(model)
    })
    
    return lists
}

//歌曲榜单
public class RankingModel: MenuItemModel {
    var name : String = ""
    var id : String = ""
    
    init(name:String, id:String, code:Int) {
        self.name = name
        self.id = id
        super.init(title: name, code: code)
    }
}

public func generateRankingModels() -> [RankingModel] {
    
    let rankingList = [
        ("云音乐新歌榜","3779629"),
        ("云音乐热歌榜","3778678"),
        ("网易原创歌曲榜","2884035"),
        ("云音乐飙升榜","19723756"),
        ("云音乐电音榜","10520166"),
        ("UK排行榜周榜","180106"),
        ("美国Billboard周榜","60198"),
        ("KTV嗨榜","21845217"),
        ("iTunes榜","11641012"),
        ("Hit FM Top榜","120001"),
        ("日本Oricon周榜","60131"),
        ("韩国Melon排行榜周榜","3733003"),
        ("韩国Mnet排行榜周榜","60255"),
        ("韩国Melon原声周榜","46772709"),
        ("中国TOP排行榜(港台榜)","112504"),
        ("中国TOP排行榜(内地榜)","64016"),
        ("香港电台中文歌曲龙虎榜","10169002"),
        ("华语金曲榜","4395559"),
        ("中国嘻哈榜","1899724"),
        ("法国 NRJ EuroHot 30周榜","27135204"),
        ("台湾Hito排行榜","112463"),
        ("Beatport全球电子舞曲榜","3812895")
    ]
    
    var itemArr : [RankingModel] = []
    var code = 0
    rankingList.forEach {
        let item = RankingModel.init(name: $0.0, id: $0.1, code: code)
        itemArr.append(item)
        code = code + 1
    }
    return itemArr
}

//搜索类型
public class SearchModel:MenuItemModel {
    var content : String = ""
    var type : SearchType = SearchType.Song
    
    init(itemTitle:String, content:String, code:Int) {
        self.content = content
        super.init(title: itemTitle, code: code)
    }
}


public func generateSearchTypeModels(content:String) -> [SearchModel] {
    let menuData = [("歌曲",0),
                    ("歌手",1),
                    ("专辑",2),
                    ("歌单",3)]
    var itemArr : [SearchModel] = []
    menuData.forEach {
        let model = SearchModel.init(itemTitle: $0.0, content: content, code: $0.1)
        itemArr.append(model)
    }
    
    return itemArr
}

//帮助
public func generateHelpModels() -> [MenuItemModel] {
    let helpData = ["↑"+6.space+"上移动",
                    "↓"+6.space+"下移动",
                    "←"+6.space+"上一页",
                    "→"+6.space+"下一页",
                    "↵"+6.space+"选中",
                    "space"+2.space+"播放/暂停",
                    "/"+6.space+"返回上一级菜单",
                    ","+6.space+"上一首",
                    "."+6.space+"下一首",
                    "["+6.space+"音量-",
                    "]"+6.space+"音量+",
                    "a"+6.space+"添加到收藏",
                    "q"+6.space+"退出",
                    "w"+6.space+"退出且登出账户",
                    "s"+6.space+"搜索",
                    "d"+6.space+"登录",
                    "f"+6.space+"播放列表",
                    "g"+6.space+"可至github进行反馈，帮助Qsic变更好",
//                    "h"+6.space+"隐藏dancer",
                    "1"+6.space+"单曲循环",
                    "2"+6.space+"顺序播放",
                    "3"+6.space+"随机播放"]
    var index : Int = 0
    var models : [MenuItemModel] = []
    helpData.forEach {
        let model = MenuItemModel.init(title: $0, code: index)
        models.append(model)
        index = index + 1
    }
    return models
}

public func generateListClassModels() -> [MenuItemModel] {
    let classification = [("语种",0),
                          ("风格",1),
                          ("场景",2),
                          ("情感",3),
                          ("主题",4)]
    var models : [MenuItemModel] = []
    classification.forEach {
        let model = MenuItemModel.init(title: $0.0, code: $0.1)
        models.append(model)
    }
    return models
}

public enum ClassType: Int {
    case Languages
    case Style
    case Scenario
    case Emotion
    case Theme
}

public func generateSongListModels(type:ClassType) -> [MenuItemModel] {
    var secondClassArr: [String] = []
    switch type {
    case .Languages:
        secondClassArr = ["华语","欧美","日语","韩语","粤语","小语种"]
    case .Style:
        secondClassArr = ["流行","摇滚","民谣","电子","舞曲","说唱","轻音乐","爵士","乡村","R&B/Soul","古典","民族","英伦","金属","朋克","蓝调","雷鬼","世界音乐","拉丁","另类/独立","New Age","古风","后摇","Bossa Nova"]
    case .Scenario:
        secondClassArr = ["清晨","夜晚","学习","工作","午休","下午茶","地铁","驾车","运动","旅行","散步","酒吧"]
    case .Emotion:
        secondClassArr = ["怀旧","清新","浪漫","性感","伤感","治愈","放松","孤独","感动","兴奋","快乐","安静","思念"]
    case .Theme:
        secondClassArr = ["影视原声","ACG","校园","游戏","70后","80后","90后","网络歌曲","KTV","经典","翻唱","吉他","钢琴","器乐","儿童","榜单","00后"]
    }
    
    var index : Int = 0
    var models : [MenuItemModel] = []
    secondClassArr.forEach {
        let model = MenuItemModel.init(title: $0, code: index)
        models.append(model)
        index = index + 1
    }
    return models
}


