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
    
    public init(title:String) {
        self.title = title
    }
}

public class ArtistModle: MenuItemModel {
    var name : String = ""
    var id :String = ""
    
    init(itemDic:Dictionary<String, Any>) {
        self.name = itemDic["name"] as! String
        self.id = (itemDic["id"] as! NSNumber).stringValue
        super.init(title: self.name)
    }
}


public func generateArtistModles(data:Data) -> [ArtistModle] {
    let dic = data.jsonDic()
    guard dic != nil else {return []}
    var artists : [ArtistModle] = []
    if let arr = dic!["artists"] as? NSArray{
        arr.forEach({ (artist) in
            let artist = ArtistModle.init(itemDic: artist as! Dictionary<String, Any>)
            artists.append(artist)
        })
    }
    return artists
}


extension Data {
    func jsonDic() -> [String : Any]? {
        if let dic = try? JSONSerialization.jsonObject(with: self, options: .allowFragments) as! [String : Any] {
            return dic
        } else {
            return nil
        }
    }
}




