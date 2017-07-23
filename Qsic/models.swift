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
    if let dic = data.jsonDic() {
        var artists : [ArtistModel] = []
        if let arr = dic["artists"] as? NSArray{
            var code = 0
            arr.forEach {
                let artist = ArtistModel.init(itemDic: $0 as! Dictionary<String, Any>, code: code)
                artists.append(artist)
                code = code + 1
            }
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
    var quality : String?
    
    init(itemDic:Dictionary<String, Any>, code:Int) {
    
        self.name = itemDic["name"] as! String
        self.id = (itemDic["id"] as! NSNumber).stringValue//dfsId是什么
        self.mp3Url = itemDic["mp3Url"] as? String
        self.quality = itemDic["itemDic"] as? String
        super.init(title: self.name, code: code)
    }
}

public func generateSongModels(data:Data) -> [SongModel] {
    
    if let dic = data.jsonDic() {
        var songs : [SongModel] = []
        if let arr = dic["hotSongs"] as? NSArray{
            var code = 0
            
            arr.forEach({ (item) in
                var itemDic : [String : Any] = [:]
                let item = item as! [String : Any]
                itemDic["name"] = item["name"]
                itemDic["id"] = item["id"]
                itemDic["mp3Url"] = item["mp3Url"]
                itemDic["quality"] = "hMusic"
                
                let song = SongModel.init(itemDic: itemDic, code: code)
                songs.append(song)
                code = code + 1
            })
        }
        return songs
    }
    return []
}

//专辑列表
public class AlbumModel:MenuItemModel {
    var name : String = ""
    var id : String = ""
//    var 
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
    var url : String = ""
    
    init(name:String, url:String, code:Int) {
        self.name = name
        self.url = url
        super.init(title: name, code: code)
    }
}

public func generateRankingModels() -> [RankingModel] {
    
    let rankingList = [
        ("云音乐新歌榜","/discover/toplist?id=3779629"),
        ("云音乐热歌榜","/discover/toplist?id=3778678"),
        ("网易原创歌曲榜","/discover/toplist?id=2884035"),
        ("云音乐飙升榜","/discover/toplist?id=19723756"),
        ("云音乐电音榜","/discover/toplist?id=10520166"),
        ("UK排行榜周榜","/discover/toplist?id=180106"),
        ("美国Billboard周榜","/discover/toplist?id=60198"),
        ("KTV嗨榜","/discover/toplist?id=21845217"),
        ("iTunes榜","/discover/toplist?id=11641012"),
        ("Hit FM Top榜","/discover/toplist?id=120001"),
        ("日本Oricon周榜","/discover/toplist?id=60131"),
        ("韩国Melon排行榜周榜","/discover/toplist?id=3733003"),
        ("韩国Mnet排行榜周榜","/discover/toplist?id=60255"),
        ("韩国Melon原声周榜","/discover/toplist?id=46772709"),
        ("中国TOP排行榜(港台榜)","/discover/toplist?id=112504"),
        ("中国TOP排行榜(内地榜)","/discover/toplist?id=64016"),
        ("香港电台中文歌曲龙虎榜","/discover/toplist?id=10169002"),
        ("华语金曲榜","/discover/toplist?id=4395559"),
        ("中国嘻哈榜","/discover/toplist?id=1899724"),
        ("法国 NRJ EuroHot 30周榜","/discover/toplist?id=27135204"),
        ("台湾Hito排行榜","/discover/toplist?id=112463"),
        ("Beatport全球电子舞曲榜","/discover/toplist?id=3812895")
    ]
    
    var itemArr : [RankingModel] = []
    var code = 0
    rankingList.forEach {
        let item = RankingModel.init(name: $0.0, url: "http://music.163.com" + $0.1, code: code)
        itemArr.append(item)
        code = code + 1
    }
    return itemArr
}

//
