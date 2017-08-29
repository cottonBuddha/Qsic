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
            songArr = arr//这里的dic命名,包括jsondic方法，要改一下
        } else if let arr = (dic["result"] as? NSDictionary)?["songs"] as? NSArray {
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

//歌曲榜单
public class RankingModel:MenuItemModel {
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
                    ("专辑",2)]
    var itemArr : [SearchModel] = []
    menuData.forEach {
        let model = SearchModel.init(itemTitle: $0.0, content: content, code: $0.1)
        itemArr.append(model)
    }
    
    return itemArr
}

//帮助
public func generateHelpModels() -> [MenuItemModel] {

    let helpData = [
                    "↑"+6.space+"上移动",
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
//                    "a"+6.space+"添加到收藏",
                    "q"+6.space+"退出",
                    "w"+6.space+"退出且登出账户",
                    "s"+6.space+"搜索",
                    "d"+6.space+"登录",
                    "f"+6.space+"播放列表",
                    "g"+6.space+"可至github进行反馈，帮助Qsic变更好",
                    "h"+6.space+"隐藏dancer",
                    "1"+6.space+"单曲循环",
                    "2"+6.space+"顺序播放",
                    "3"+6.space+"随机播放"
                                       ]
    var index : Int = 0
    var models : [MenuItemModel] = []
    helpData.forEach {
        let model = MenuItemModel.init(title: $0, code: index)
        models.append(model)
        index = index + 1
    }
    return models
}
