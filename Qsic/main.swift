//
//  main.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/7/7.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation

//API.shared.GET(urlStr: "http://music.163.com/api/playlist/detail", params: ["id":"3779629"]) { (data, response, error) in
//
//    let str = String.init(data: data!, encoding: String.Encoding.utf8)
////    let result = str?.matchRegExp("/song\\?id=(\\d+)")
////    print(result ?? "")
//    let jsonDic = data?.jsonDic()
//    let arr = (jsonDic?["result"] as! [String:Any])["tracks"] as? NSArray
//    
//    print(jsonDic ?? "jqs")
//    
//}

//API.shared.rankingSongs(rankingId: "3779629") { (songs) in
//    print(songs)
//}

//API.shared.getSongsOfArtist(artistId: "6452") { (songs) in
//    print(songs)
//}


//let A_ASCII = UnicodeScalar("⠋")
//print(A_ASCII)

//API.shared.songDetail(rankingUrl: "http://music.163.com/discover/toplist?id=180106") { (songs) in
//    print(songs)
//}



//let url = "http://m2.music.126.net/RMJR7wDullRqppBk8dhLow==/3435973841155597.mp3"
//let player = try AVAudioPlayer(contentsOf: URL.init(string: url)!)
//
//player.play()

//API.shared.login(username: "", password: "")
//API.shared.phoneLogin(phoneNumber: "18662867625", password: "jqsjsssjp1")
//API.shared.recommendPlaylist()

//API.shared.rankings(completionHandler: { (rankings) in
//    let newDic = rankings.split(num: 10)
//    print(newDic)
//})

//API.shared.getAlbumsOfArtist(artistId: "6452") { (albums) in
//    print(albums)
//}

//API.shared.getSongsOfAlbum(albumId: "18877") { (songs) in
//    print(songs)
//}

//API.shared.songDetail(rankingId: "3779629") { (models) in
//    print(models)
//}
//

//API.shared.search(type: .Song, content: "周杰伦") { (type, models) in
//    print(models)
//}


//API.shared.recommendPlaylist { (models) in
//    print(models)
//}

//API.shared.phoneLogin(phoneNumber: "18662867625", password: "jqsjsssjp1") { (name) in
//    print(name)
//}

//RunLoop.main.run()


//let i = getch()
//print(i)

//let str = readLine()
//print(str)

//185904
//let mp3String = "http://baxiang.qiniudn.com/chengdu.mp3"
//let url = URL.init(string: mp3String)
//
//QSAudioPlayer.init(url: url!)

//API.shared.getSongUrls(ids: ["185904","422790564"]) { (urls) in
//    print(urls ?? "")
//}

//private var player : QSPlayer = QSPlayer.shared
//
//API.shared.getSongsOfAlbum(albumId: "18895") { (songModels) in
//    player.songList = songModels
//    player.currentIndex = 0
//    player.play()
//}

//API.shared.getSongUrl(id: "28700274") { (url) in
//    player.playSong(url: url!)
//}
//
//3.delay {
//    player.next()
//}
//private var eventHandlerRef: EventHandlerRef? = nil
//private var forwardKey: EventHotKeyRef? = nil
//private var backwardKey: EventHotKeyRef? = nil
//private var playPauseKey: EventHotKeyRef? = nil
//
//var eventType = EventTypeSpec.init(eventClass: OSType.init(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
//
//func registerHotKey() {
//    
//    let forwardKeyID = EventHotKeyID.init(signature: OSType.init(1), id: UInt32(7))
//    let backwardKeyID = EventHotKeyID.init(signature: OSType.init(62), id: UInt32(62))
//    let playPauseKeyID = EventHotKeyID.init(signature: OSType.init(64), id: UInt32(64))


//    InstallEventHandler(GetApplicationEventTarget(), eventHandle, 1, &eventType, nil, nil)
    
//    InstallEventHandler(GetApplicationEventTarget(), {(nextHanlder, theEvent, userData) -> OSStatus in
////        DispatchQueue.main.async {
//            var hotKey = EventHotKeyID()
//            print("进来了")
//            GetEventParameter(theEvent, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKey)
//            if hotKey.id == 6 {
//                print("往后")
//            }
//            
//            if hotKey.id == 64 {
//                print("暂停")
//                
//            }
//            
//            if hotKey.id == 65 {
//                print("往前")
//                
//            }
//        
////        }
//        return 0
//
//    }, 1, &eventType, nil, nil)

    
//    let s = RegisterEventHotKey(7, UInt32(kEventHotKeyExclusive), forwardKeyID, GetApplicationEventTarget(), 0, &forwardKey)
////    RegisterEventHotKey(62, 0, backwardKeyID, GetApplicationEventTarget(), 0, &backwardKey)
////    RegisterEventHotKey(64, 0, playPauseKeyID, GetApplicationEventTarget(), 0, &playPauseKey)
//    UnregisterEventHotKey(forwardKey)
//
//}
//
//func eventHandle(_: EventHandlerCallRef?, _: EventRef?, _: UnsafeMutableRawPointer?) -> OSStatus {
//    print("哈哈哈哈哈哈")
//
//    return 0
//}






//registerHotKey()
//var j = NX_KEYTYPE_PLAY
//RunLoop.main.run()
//print("Ain\u{2019}t this a beautiful day")
//initscr()
//keypad(stdscr, true)
//noecho()
//raw()
////QSProgress().fireFliesShining()
//
//getch()
//endwin()
QSMusicController().start()






