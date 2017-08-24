//
//  API.swift
//  Qsic
//
//  Created by 江齐松 on 2017/7/14.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
import CFNetwork

public enum SearchType : Int{
    case Song = 1
    case Album = 10
    case Artist = 100
}

class API {
    
    private static let sharedInstance = API()
    
    open class var shared: API {
        get {
            return sharedInstance
        }
    }
    
    private init() {}

    let headerDic = [
        "Accept": "*/*",
        "Accept-Encoding": "gzip,deflate,sdch",
        "Accept-Language": "zh-CN,zh;q=0.8,gl;q=0.6,zh-TW;q=0.4",
        "Connection": "keep-alive",
        "Content-Type": "application/x-www-form-urlencoded",
        "Host": "music.163.com",
        "Referer": "http://music.163.com/",
        "User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.152 Safari/537.36",
        "Set-Cookie": "appver=1.5.2"
    ]
    
    let urlDic = [
        //登录
        "login" : "https://music.163.com/weapi/login",
        //手机登录
        "phoneLogin" : "https://music.163.com/weapi/login/cellphone",
        //签到
        "signin" : "https://music.163.com/weapi/point/dailyTask",
        //歌手
        "artist" : "http://music.163.com/api/artist/top",
        //歌手曲目
        "songOfArtist" : "http://music.163.com/api/artist",
        //歌手专辑
        "albumOfArtist" : "http://music.163.com/api/artist/albums",
        //歌曲详情
        "songDetail" : "https://music.163.com/api/song/detail",
        //排行榜
        "ranking" : "http://music.163.com/discover/toplist",
        //专辑歌曲
        "songsOfAlbum" : "http://music.163.com/api/album/",
        //推荐
        "recommend" : "https://music.163.com/weapi/v1/discovery/recommend/songs",
        //搜索
        "search" : "https://music.163.com/api/search/get"
    ]
    
    var finish : Bool = false
    
    func GET(urlStr:String, params:[String:String]?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        let components = NSURLComponents.init(string: urlStr)
        var queryItems : [URLQueryItem] = []
        if (params != nil) && (params!.count > 0) {
            params?.forEach({ (key,value) in
                let queryItem : URLQueryItem = URLQueryItem.init(name: key, value: value)
                queryItems.append(queryItem)
            })
        }
        components?.queryItems = queryItems

        let url = components!.url!
        let session = URLSession.shared
        var request = URLRequest.init(url: url)
        request.allHTTPHeaderFields = self.headerDic
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
                completionHandler(data,response,error)
        }
        
        dataTask.resume()
    }
    
    func POST(urlStr:String, params:[String:Any]?,encrypt:Bool = true, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        let url : URL = URL.init(string: urlStr)!

        var request = URLRequest.init(url: url)
        request.allHTTPHeaderFields = self.headerDic

        request.httpMethod = "POST"
        
        if params == nil {
             request.httpBody = nil
        }
        
        if encrypt {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: params!, options: .init(rawValue: 0))
                let jsonStr = String.init(data: jsonData, encoding: String.Encoding.utf8)
                let bodyData = self.encryptedRequest(content: jsonStr!)
                request.httpBody = bodyData!
            } catch {
                request.httpBody = nil
            }
        } else {
            
            do {
                request.httpBody = self.dicToBodyData(dic: params as! [String : String])
            } catch {
                
            }
        }

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            completionHandler(data,response,error)
        }
        
        dataTask.resume()
    }
    
    //登录
    func login(account:String, password:String, completionHandler : @escaping (_ userName:String)->()) {
        let url = self.urlDic["login"]
        if account.matchRegExp("^1[0-9]{10}$").count > 0 {
            phoneLogin(phoneNumber: account, password: password, completionHandler: completionHandler)
        } else {
            let loginfo = ["username":account,"password":password,"rememberLogin":"true"]
            self.POST(urlStr: url!, params: loginfo) { (data, response, error) in
                var accountName : String = ""
                if let arr = data?.jsonDic() as? NSArray {
                    if let profile = (arr.firstObject as? NSDictionary)?["profile"] as? NSDictionary {
                        accountName = profile["nickName"] as! String
                    }
                }
                completionHandler(accountName)
            }
        }
    }
    
    //手机登录
    func phoneLogin(phoneNumber:String, password:String, completionHandler : @escaping (_ userName:String)->()) {
        let url = self.urlDic["phoneLogin"]
        let passwordMD5 = CC.digest(password.data(using: String.Encoding.utf8)!, alg: .md5).hexString
        let loginfo = ["phone":phoneNumber,"password":passwordMD5,"rememberLogin":"true"]
        self.POST(urlStr: url!, params: loginfo) { (data, response, error) in
            
            var accountName : String = ""
            if let dic = data?.jsonDic() as? NSDictionary {
                if let profile = dic["profile"] as? NSDictionary {
                    accountName = profile["nickname"] as! String
                }
            }
            completionHandler(accountName)
        }
    }
    //签到
    func dailySignin(type:String) {
        
    }
    
    
    //用户歌单
    func userPlaylist(uid:String, offset:Int, limit:Int) {
        
    }
    
    //每日推荐歌单
    func recommendPlaylist(completionHandler : @escaping ([SongModel])->()) {
        let urlStr = self.urlDic["recommend"]
        let phoneUrl = self.urlDic["phoneLogin"]

        let cookies = HTTPCookieStorage.shared.cookies(for: URL.init(string: phoneUrl!)!)
        //print(cookies)
        var csrf = ""
        cookies?.forEach {
            if $0.name == "__csrf" {
                csrf = $0.value
            }
        }
        let params = ["limit":20, "csrf_token":""] as [String : Any]
        self.POST(urlStr: urlStr!, params: params) { (data, response, error) in
            let models = generateSongModels(data: data!)
            completionHandler(models)
        }
    }
    
    //榜单
    func rankings(completionHandler : @escaping ([RankingModel])->()) {
        let models = generateRankingModels()
        completionHandler(models)
    }
    
    func songDetail(rankingId:String, completionHandler : @escaping ([SongModel])->()) {
//        print(Thread.current)
        let rankingUrl = urlDic["ranking"]
        let detailUrl = urlDic["songDetail"]
        var idResultStr : String = ""

        self.GET(urlStr: rankingUrl!, params: ["id":rankingId]) { (data, response, error) in
            
            let str = String.init(data: data!, encoding: String.Encoding.utf8)
            let regResult = str?.matchRegExp("/song\\?id=(\\d+)")
            regResult?.forEach {
                let index = $0.index($0.startIndex, offsetBy: 9)
                let subStr = $0.substring(from: index)
                idResultStr.append(subStr + ",")
            }
            
            let index = idResultStr.index(idResultStr.endIndex, offsetBy: -1)
            idResultStr = idResultStr.substring(to: index)
            let params = ["ids":"[\(idResultStr)]"]
            
            self.GET(urlStr: detailUrl!, params: params) { (data, response, error) in
                if data != nil {
                    let models = generateSongModels(data: data!)
                    completionHandler(models)
                } else {
                    
                }
            }

            }
        

    }

    //歌手
    func artists(completionHandler : @escaping ([ArtistModel])->()) {
        let url = urlDic["artist"]
        let params = ["offset":"0","limit":"100"]
        self.GET(urlStr: url!, params: params) { (data, response, error) in

            if data != nil {
                let models = generateArtistModles(data: data!)
                completionHandler(models)
            } else {

            }
        }
    }
    
    //歌手热门歌曲
    func getSongsOfArtist(artistId:String,completionHandler : @escaping ([SongModel])->()) {
        let urlStr = self.urlDic["songOfArtist"]! + "/" + artistId
        self.GET(urlStr: urlStr, params: nil) { (data, response, error) in
            let models = generateSongModels(data: data!)
            completionHandler(models)
        }

    }
    
    //歌手专辑
    func getAlbumsOfArtist(artistId:String, completionHandler : @escaping ([AlbumModel])->()) {
        let urlStr = self.urlDic["albumOfArtist"]! + "/" + artistId
        let params = ["offset":"0","limit":"100"]
        self.GET(urlStr: urlStr, params: params) { (data, response, error) in
            let models = generateAlbumModels(data: data!)
            completionHandler(models)
        }
    }
    
    //专辑歌曲
    func getSongsOfAlbum(albumId:String,completionHandler : @escaping ([SongModel])->()) {
        let urlStr = self.urlDic["songsOfAlbum"]! + "/" + albumId
        self.GET(urlStr: urlStr, params: nil) { (data, response, error) in
            let models = generateSongModels(data:data!)
            completionHandler(models)
        }
        
    }
    
    //搜索
    func search(type:SearchType = .Song,content:String,completionHandler : @escaping (SearchType,[MenuItemModel])->()) {
        let urlStr = self.urlDic["search"];
        let params = ["s":content, "limit":"60", "type":"\(type.rawValue)", "offset":"0"] as [String : Any];
        self.POST(urlStr: urlStr!, params: params ,encrypt: false) { (data, response, error) in
            var models : [MenuItemModel] = []
            switch type {
            case .Song :
                models = generateSongModels(data:data!)
            case .Album:
                models = generateAlbumModels(data: data!)
            case .Artist:
                models = generateArtistModles(data: data!)
            }
            completionHandler(type,models)
            
        }
    }
    
    func getSongUrl(id:String,completionHandler : @escaping (String?)->()) {
        let params = ["br": 128000, "csrf_token":"", "ids":"[\(id)]"] as [String : Any]
        self.POST(urlStr: "https://music.163.com/weapi/song/enhance/player/url", params: params) { (data, response, error) in
            //print(data?.jsonDic() ?? "jqs")
            if let dic = data?.jsonDic() as? NSDictionary {
                let dataArr = dic["data"] as! NSArray
                let dataDic = dataArr.lastObject as! NSDictionary
                completionHandler(dataDic["url"] as? String)
            }
        }
    }
    
    func getSongUrls(ids:[String],completionHandler : @escaping ([String:String]?)->()) {
        let idsStr = "[" + ids.joined(separator: ",") + "]"
        let params = ["br": 128000, "csrf_token":"", "ids":idsStr] as [String : Any]
        self.POST(urlStr: "https://music.163.com/weapi/song/enhance/player/url", params: params) { (data, response, error) in
            //print(data?.jsonDic() ?? "jqs")
            var idAndUrlPairs : [String:String] = [:]
            if let dic = data?.jsonDic() as? NSDictionary {
                let dataArr = dic["data"] as! NSArray
                dataArr.forEach {
                    let dataDic = $0 as! NSDictionary
                    let id = (dataDic["id"] as? NSNumber)?.stringValue
                    if let url = dataDic["url"] as? String {
                        idAndUrlPairs.updateValue(url, forKey: id!)
                    }
                }
                completionHandler(idAndUrlPairs)
            }
        }
    }
    
    func deleteCookie() {

        let phoneUrl = self.urlDic["phoneLogin"]
        let cookieJar = HTTPCookieStorage.shared
        let cookies = cookieJar.cookies(for: URL.init(string: phoneUrl!)!)
        //print(cookies)
        cookies?.forEach {
            cookieJar.deleteCookie($0)
        }

    }
    
    
    let modulus = "00e0b509f6259df8642dbc35662901477df22677ec152b5ff68ace615bb7b725152b3ab17a876aea8a5aa76d2e417629ec4ee341f56135fccf695280104e0312ecbda92557c93870114af6c9d05c4f7f0c3685b7a46bee255932575cce10b424d813cfe4875d3e82047b97ddef52741d546b8e289dc6935b3ece0462db0a22b8e7"
    let nonce = "0CoJUm6Qyw8W8jud"
    let pubKey = "010001"
    
    func encryptedRequest(content:String) -> Data? {
        let secKey = createSecretKey()
        let encContent = aesEncrypt(content: aesEncrypt(content: content, secKey: nonce)!, secKey: secKey)
        let encSec = rsaEncrypt(content: secKey, pubKey: pubKey, modulus: modulus)
        let bodyStr = "params="+escape(encContent!)+"&"+"encSecKey="+escape(encSec!)
        let bodyData = bodyStr.data(using: String.Encoding.utf8)
        return bodyData
    }
    
    func dicToBodyData(dic:[String:String]) -> Data? {
        var bodyStr = ""
        dic.forEach {
            let paramStr = $0.key + "=" + $0.value + "&"
            bodyStr.append(paramStr)
        }
        return bodyStr.data(using: String.Encoding.utf8)
    }
    
    //16位随机字符串
    func createSecretKey() -> String{
        let min : UInt32 = 33
        let max : UInt32 = 127
        var string = ""
        (0..<16).forEach { (num) in
            let randomNum = arc4random_uniform(max-min)+min
            string.append(Character.init(UnicodeScalar.init(randomNum)!))
        }
        return string
    }

    //AES加密(pass)
    func aesEncrypt(content:String, secKey:String) -> String?{
        
        let iv = "0102030405060708".data(using: String.Encoding.utf8)
        
        let data = try? CC.crypt(.encrypt, blockMode: .cbc, algorithm: .aes, padding: .pkcs7Padding, data: content.data(using: String.Encoding.utf8)!, key: secKey.data(using: String.Encoding.utf8)!, iv: iv!)
        
        if data != nil {
            return data?.base64EncodedString()
        } else {
            return nil
        }
    }
    
    //RSA加密(pass)
    func rsaEncrypt(content:String, pubKey:String, modulus:String) -> String?{
        let radix = 16
        let rText = String.init(content.characters.reversed())
        let biText = BInt.init(number: (rText.data(using: String.Encoding.utf8)?.hexString)!, withBase: radix)
        let biEx = BInt.init(number: pubKey, withBase: radix)
        let biMod = BInt.init(number: modulus, withBase: radix)
        let biRet = mod_exp(biText, biEx, biMod)
        let encText = biRet.hex
        
        return addPadding(encText: encText, modulus: modulus)
    }
    
    
    private func addPadding(encText:String, modulus:String) -> String {
        var ml = modulus.characters.count
        for char in modulus.characters {
            if char == "0" {
                ml = ml - 1
            } else {
                break
            }
        }
        
        let num = ml - encText.characters.count
        var prefix = ""
        (0..<num).forEach { (num) in
            prefix.append(Character.init("0"))
        }
        
        return prefix + encText
    }
    
    public func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        var escaped = ""
        
        let batchSize = 50
        var index = string.startIndex
        
        while index != string.endIndex {
            let startIndex = index
            let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
            let range = startIndex..<endIndex
            
            let substring = string.substring(with: range)
            
            escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? substring
            
            index = endIndex
        }
        
        return escaped
    }

}

