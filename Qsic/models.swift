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

public class QSMenuModel {
    var title : String = ""
    var type : String = ""
    var items : [MenuItemModel] = []
    var rowsNum : Int = 10
    var currentItemCode : Int = 0 {
        didSet {
            let lastCode = self.items.count - 1
            currentItemCode = currentItemCode > lastCode ? lastCode : (currentItemCode < 0 ? 0 : currentItemCode)        }
    }
    
    init(title:String, type:String, items:[MenuItemModel], rowsNum:Int = 10, currentItemCode:Int) {
        self.title = title
        self.items = items
        self.rowsNum = rowsNum
        let lastCode = items.count - 1
        self.currentItemCode = currentItemCode > lastCode ? lastCode : (currentItemCode < 0 ? 0 : currentItemCode)
    }
}


