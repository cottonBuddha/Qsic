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
    
//    var listId : String = ""
    var songList : [SongModel] = []
    var currentIndex : Int = 0
    private var urlDic : [String:String] = [:]
    
    var isPlaying : Bool = false
    var isPause : Bool = false
    
    var playMode : PlayMode = .OrderCycle
    
    var streamer : QSAudioStreamer?
    
    func play(songList:[SongModel]) {
        self.songList = songList
        play()
    }
    
    func play() {
        
        let id = songList[currentIndex].id
        if urlDic[id] != nil {
            playSong(url: urlDic[id]!)
        } else {
            let ids = getAllSongId(songList: songList)
            API.shared.getSongUrls(ids: ids) { (urlDic) in
                self.urlDic = urlDic!
                if let url = self.urlDic[id] {
                    self.playSong(url: url)
                }
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
        let nextIndex = getIndex(type: .Next)
        let id = self.songList[nextIndex].id
        let url = urlDic[id]
        playSong(url: url!)
    }
    
    func previous() {
        let previousIndex = getIndex(type: .Previous)
        let id = self.songList[previousIndex].id
        let url = urlDic[id]
        playSong(url: url!)
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
    
    func playSong(url:String) {
        if streamer != nil {
            streamer?.stop()
            streamer = nil
        }
        streamer = QSAudioStreamer.init(url: URL.init(string: url)!)
        streamer?.delegate = self
    }
    
    
    private func getIndex(type:IndexType) -> Int {

        if playMode == .OrderCycle || playMode == .SingleCycle {
            
            currentIndex = currentIndex + type.rawValue
            if currentIndex > self.urlDic.count {
                currentIndex = 0
            }
            
            if currentIndex < 0 {
                currentIndex = self.urlDic.count - 1
            }
            
        } else if playMode == .ShuffleCycle {
            currentIndex = (0..<urlDic.count).random
        
        }

        return currentIndex
    }
    
    func playingDidEnd() {
//        if playMode == .OrderCycle || playMode == .ShuffleCycle {
//            next()
//        } else {
//            singleCycle()
//        }
    }
    
    func playingDidStart() {

    }
    
    func handleWithKeyEvent(keyCode:Int32) {
        switch keyCode {
        case KEY_SPACE:
            if isPlaying {
                pause()
            } else {
                resume()
            }
        case KEY_L_C_BRACE:
            previous()
        case KEY_R_C_BRACE:
            next()
        default:
            break
        }
        
    }
}
