//
//  QSPlayer.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/7/22.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation

public enum PlayMode : Int {
    case SingleCycle
    case OrderCycle
    case ShuffleCycle
}

enum IndexType : Int {
    case Next = 1
    case Previous = -1
}

class QSPlayer : NSObject,AudioStreamerProtocol,KeyEventProtocol {
    
    private static let sharedInstance = QSPlayer()
    
    open class var shared: QSPlayer {
        get {
            return sharedInstance
        }
    }
    
    var dancer: QSProgressWidget?
    
//    var listId : String = ""
    var songList : [SongModel] = []
    var currentIndex : Int = 0
    private var urlDic : [String:String] = [:]
    
    var isPlaying : Bool = false {
        didSet {
            if isPlaying {
                dancer?.load()
            } else {
                dancer?.pause()
            }
        }
    }
    
    var playMode : PlayMode = .OrderCycle
    
    var streamer : QSAudioStreamer?
    
    var volumeValue : Float32 = 6
    
    private override init() {
        super.init()
        dancer = QSProgressWidget.init(startX: 0, startY: 0, type: .Dance)
    }
    
    func play(songList:[SongModel]) {
        self.songList = songList
        play()
    }
    
    func play() {
        if !isPlaying {
            isPlaying = true
        }
        let id = songList[currentIndex].id
        if urlDic[id] != nil {
            playSong(url: urlDic[id]!)
        } else {
            let ids = getAllSongId(songList: songList)
            if ids.count <= 60 {
                API.shared.getSongUrls(ids: ids) { (urlDic) in
                    self.urlDic = urlDic!
                    if let url = self.urlDic[id] {
                        self.playSong(url: url)
                    } else {
                        //to do sth
                    }
                }
            } else {
                API.shared.getSongUrl(id: ids[currentIndex], completionHandler: { (url) in
                    self.urlDic[id] = url
                    self.playSong(url: url!)
                })
            }
        }
    }
    
    func getAllSongId(songList:[SongModel]) -> [String] {
        var urls : [String] = []
        songList.forEach {
            urls.append($0.id)
        }
        return urls
    }

    func next() {
        pause()
        self.currentIndex = getIndex(type: .Next)
        play()
    }
    
    func previous() {
        pause()
        self.currentIndex = getIndex(type: .Previous)
        play()
    }
    
    func singleCycle() {
        
    }
    
    func pause() {
        self.isPlaying = false
        self.streamer?.pause()
    }
    
    func resume() {
        self.isPlaying = true
        self.streamer?.play()
    }
    
    func volumeUp() {
        if streamer != nil {
            volumeValue = volumeValue + 0.5 > 15 ? 15 : volumeValue + 0.5
            streamer?.setVolume(value: volumeValue)
        }
    }
    
    func volumeDown() {
        if streamer != nil {
            volumeValue = volumeValue - 0.5 < 0 ? 0 : volumeValue - 0.5
            streamer?.setVolume(value: volumeValue)
        }
    }
    
    func playSong(url:String) {
        if streamer != nil {
            streamer?.stop()
            streamer = nil
        }
        streamer = QSAudioStreamer.init(url: URL.init(string: url)!)
        streamer?.delegate = self
        streamer?.setVolume(value: volumeValue)
    }
    
    
    private func getIndex(type:IndexType) -> Int {

        if playMode == .OrderCycle || playMode == .SingleCycle {
            
            currentIndex = currentIndex + type.rawValue
            if currentIndex >= self.songList.count {
                currentIndex = 0
            }
            
            if currentIndex < 0 {
                currentIndex = self.songList.count - 1
            }
            
        } else if playMode == .ShuffleCycle {
//            currentIndex = (0..<urlDic.count).random
        
        }

        return currentIndex
    }
    
    func playingDidEnd() {
        if playMode == .OrderCycle || playMode == .ShuffleCycle {
            next()
        } else {
            singleCycle()
        }
    }
    
    func playingDidStart() {

    }
    
    func handleWithKeyEvent(keyCode:Int32) {
//        DispatchQueue.main.async {
            switch keyCode {
            case KEY_SPACE:
                if self.isPlaying {
                    self.pause()
                } else {
                    self.resume()
                }
            case KEY_L_ANGLE_EN, KEY_L_ANGLE_ZH:
                self.previous()
            case KEY_R_ANGLE_EN, KEY_R_ANGLE_ZH:
                self.next()
            case EN_L_C_BRACE, ZH_L_C_BRACE:
                self.volumeDown()
            case EN_R_C_BRACE, ZH_R_C_BRACE:
                self.volumeUp()
            default:
                break
            }
//        }
    }
}
