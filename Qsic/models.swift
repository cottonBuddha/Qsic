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

public class ArtistModle: MenuItemModel {
    var name : String = ""
    var id :String = ""
    
    init(itemDic:Dictionary<String, Any>, code:Int) {
        self.name = itemDic["name"] as! String
        self.id = (itemDic["id"] as! NSNumber).stringValue
        super.init(title: self.name,code: code)
    }
}


public func generateArtistModles(data:Data) -> [ArtistModle] {
    let dic = data.jsonDic()
    guard dic != nil else {return []}
    var artists : [ArtistModle] = []
    if let arr = dic!["artists"] as? NSArray{
        var code = 0
        arr.forEach {
            let artist = ArtistModle.init(itemDic: $0 as! Dictionary<String, Any>, code: code)
            code = code + 1
            artists.append(artist)
        }
    }
    return artists
}

public class QSMenuModle {
    var title : String = ""
    var items : [MenuItemModel] = []
    var rowsNum : Int = 10
    var currentRowIndex : Int = 0
    var currentPageIndex : Int = 0
    
    init(title:String, items:[MenuItemModel], rowsNum:Int, currentRowIndex:Int, currentPageIndex:Int) {
        self.title = title
        self.items = items
        self.rowsNum = rowsNum
        self.currentRowIndex = currentRowIndex
        self.currentPageIndex = currentPageIndex
    }
}


