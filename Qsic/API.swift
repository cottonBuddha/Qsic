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
        let url = URL.init(string: urlStr)!
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
            vat 
            params?.forEach({ (key,value) in
                
            })
        }
        let semaphore = DispatchSemaphore.init(value: 0)
        let session = URLSession.shared
//        let dataTask = session.dataTask(with: request, completionHandler: completionHandler)
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
    
    //推荐
    func recommendPlaylist() {
        
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
    
    
    
    
}
