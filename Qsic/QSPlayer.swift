//
//  QSPlayer.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/7/22.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
import AVFoundation

class QSPlayer {
    private static let sharedInstance = QSPlayer()
    
    open class var shared: QSPlayer {
        get {
            return sharedInstance
        }
    }
    
    var songList : [SongModel] = []
    var currentIndex : Int = 0
    var player : AVPlayer?
    
    var isPlaying : Bool = false
    var isPause : Bool = false
    
    private init() {
        player = AVPlayer.init()
    }
    
    func playCurrentIndexSong(index:Int) {
        let songModel = self.songList[index]
        self.playSong(songId: songModel.id)
    }
    
    func playSong(songId:String) {
        API.shared.getSongUrl(id: songId) { (urlStr) in
            let playerItem = AVPlayerItem(url: URL.init(string: urlStr!)!)
            self.player = AVPlayer.init(playerItem: playerItem)
            self.player?.play()
            self.isPlaying = true
        }
    }

    func next() {
        if currentIndex + 1 >= self.songList.count {
            return
        }
        currentIndex = currentIndex + 1
        let songId = self.songList[currentIndex].id
        self.playSong(songId: songId)
    }
    
    func previous() {
        if currentIndex <= 0 {
            return
        }

        currentIndex = currentIndex - 1
        let songId = self.songList[currentIndex].id
        self.playSong(songId: songId)
    }
    
    func pause() {
        self.isPlaying = false
        self.player?.pause()
    }
    
    func resume() {
        self.isPlaying = true
        self.player?.play()
    }
    
    
    
}
