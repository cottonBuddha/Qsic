//
//  API.swift
//  Qsic
//
//  Created by 江齐松 on 2017/7/14.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
import CFNetwork

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
        "Referer": "http://music.163.com/search/",
        "User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.152 Safari/537.36"
    ]
    
    let urlDic = [
        //登录
        "login" : "https://music.163.com/weapi/login",
        "phoneLogin" : "https://music.163.com/weapi/login/cellphone",
        "signin" : "http://music.163.com/weapi/point/dailyTask",
        
    
    ]
    
    
    
    
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
        let jar = HTTPCookieStorage.shared
        let cookieHeaderField = ["Set-Cookie": "appver=1.5.2"]
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: url)
        jar.setCookies(cookies, for: url, mainDocumentURL: url)
        var request = URLRequest.init(url: url)
        request.allHTTPHeaderFields = self.headerDic
        
        let semaphore = DispatchSemaphore.init(value: 0)

        let dataTask = session.dataTask(with: request) { (data, response, error) in
            completionHandler(data,response,error)
            semaphore.signal()
        }
        
        dataTask.resume()
        semaphore.wait()
    }
    
    func POST(urlStr:String, params:[String:String]?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        let url : URL = URL.init(string: "")!
        var request = URLRequest.init(url: url)
        request.httpMethod = "POST"
        if (params != nil) && (params!.count > 0){
            do {
                
                let jsonData = try JSONSerialization.data(withJSONObject: params!, options: .prettyPrinted)
                let data = encryptedRequest(content: jsonData)
                request.httpBody = data
            } catch {
                
            }
            
            
        }
        let semaphore = DispatchSemaphore.init(value: 0)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            completionHandler(data,response,error)
            semaphore.signal()
        }
        
        dataTask.resume()
        semaphore.wait()

    }
    
    //登录
    func login(username:String, password:String) {
        
    }
    
    //手机登录
    func phoneLogin(username:String, password:String) {
        
    }
    
    //签到
    func dailySignin(type:String) {
        
    }
    
    
    //用户歌单
    func userPlaylist(uid:String, offset:Int, limit:Int) {
        
    }
    
    //每日推荐歌单
    func recommendPlaylist() {
        
    }
    
    //搜索
    func search() {
        
    }
    
    //歌手单曲
    func artists() {
        
    }
    
    //歌手专辑
    func getArtistAlbum() {
        
    }
    
    
    func album() {
        
    }
    
    
    
    let modulus = "00e0b509f6259df8642dbc35662901477df22677ec152b5ff68ace615bb7b725152b3ab17a876aea8a5aa76d2e417629ec4ee341f56135fccf695280104e0312ecbda92557c93870114af6c9d05c4f7f0c3685b7a46bee255932575cce10b424d813cfe4875d3e82047b97ddef52741d546b8e289dc6935b3ece0462db0a22b8e7"
    let nonce = "0CoJUm6Qyw8W8jud"
    let pubKey = "010001"
    
    func encryptedRequest(content:Data) -> Dictionary<String, Any> {
        let secKey = createSecretKey().data(using: String.Encoding.utf8)
        let modulusData = self.modulus.data(using: String.Encoding.utf8)
        let nonceData = self.nonce.data(using: String.Encoding.utf8)
        let pubkeyData = self.pubKey.data(using: String.Encoding.utf8)
        let encData = aesEncrypt(content: aesEncrypt(content: content, secKey: nonceData!)!, secKey: secKey!)
        let encSecData = rsaEncrypt(content: secKey!, pubKey: pubkeyData!, modulus: modulusData!)
        
        return ["params": encData!, "encSecKey": encSecData!]
    }
    
    //16为随机字符串
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

    //AES加密
    func aesEncrypt(content:Data, secKey:Data) -> Data?{
//        let pad = 16 - content.characters.count % 16
//        var padString = ""
//        (0..<pad).forEach { (_) in
//            padString.append("")
//        }
//        let newContent = content.appending(padString)
        
        let iv = "0102030405060708".data(using: String.Encoding.utf8)
        
        let data = try? CC.crypt(.encrypt, blockMode: .cbc, algorithm: .aes, padding: .pkcs7Padding, data: content, key: secKey, iv: iv!)
        
        if data != nil {
            return data?.base64EncodedData()
        } else {
            return nil
        }
    }
    
    //RSA加密
    func rsaEncrypt(content:Data, pubKey:Data, modulus:Data) -> Data?{
        let data = try? CC.RSA.encrypt(content, derKey: pubKey, tag: modulus, padding: .pkcs1, digest: .sha1)
        return data
    }
}







