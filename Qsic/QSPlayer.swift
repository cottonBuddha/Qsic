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

class QSPlayer {
    
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
    
    var player : QSAudioStreamer?
    
    func play(songList:[SongModel]) {
        self.songList = songList
        play()
    }
    
    func play() {
        
        let id = songList[currentIndex].id
        if urlDic[id] != nil {
//            playSong(url: urlDic[id]!)
            player?.playNext(url: urlDic[id]!)
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
    
    func pause() {
        self.isPlaying = false
        self.player?.pause()
    }
    
    func resume() {
        self.isPlaying = true
        self.player?.play()
    }
    
    func playSong(url:String) {
        if player != nil {
            player?.stop()
            
        } else {
            player = QSAudioStreamer.init(url: URL.init(string: url)!)
        }
    }
    
    
    private func getIndex(type:IndexType) -> Int {
        var nextIndex : Int = 0
        if playMode == .OrderCycle {
            
            nextIndex = currentIndex + type.rawValue
            if nextIndex > self.urlDic.count {
                nextIndex = 0
            }
            
            if nextIndex < 0 {
                nextIndex = self.urlDic.count - 1
            }
            
        } else if playMode == .SingleCycle {
            nextIndex = currentIndex
            
        } else if playMode == .ShuffleCycle {
//            nextIndex = (0..<urls.count).random
        
        }
        
        return nextIndex
    }
    
}
