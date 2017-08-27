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

let kNotificationSongHasChanged = "notificationSongHasChanged"

class QSPlayer : NSObject,AudioStreamerProtocol,KeyEventProtocol {
    
    private static let sharedInstance = QSPlayer()
    
    open class var shared: QSPlayer {
        get {
            return sharedInstance
        }
    }
    
    var dancer: QSProgressWidget?

    var currentSongId: String?
    var songList: [SongModel] = []
    var currentIndex: Int = 0
    var isPlayingDidStart: Bool = false
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
    
    var playMode: PlayMode = .OrderCycle
    
    var streamer: QSAudioStreamer?
    
    var volumeValue: Float32 = 0.5
    
    private override init() {
        super.init()
        dancer = QSProgressWidget.init(startX: 0, startY: 0, type: .Dance)
    }
    
    func play(songList:[SongModel]) {
        self.songList = songList
        play()
    }
    
    func play() {

        guard songList.count > 0 else { return }
        let id = songList[currentIndex].id
        NotificationCenter.default.post(Notification.init(name:
            Notification.Name(rawValue: kNotificationSongHasChanged)))
        if let url = urlDic[id] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            let deadTimeStr = url.components(separatedBy: "/")[3]
            guard deadTimeStr.characters.count == 14 else { return }
            let deadTime = dateFormatter.date(from: deadTimeStr)
            let currentTime = Date.init()
            let result = deadTime?.compare(currentTime)
            if result == ComparisonResult.orderedDescending {
                playSong(url: url)
                currentSongId = id
            } else {
                urlDic.removeAll()
                play()
            }
        } else {
            let ids = getAllSongId(songList: songList)
            if ids.count <= 60 {
                API.shared.getSongUrls(ids: ids) { (urlDic) in
                    self.urlDic = urlDic!
                    if let url = self.urlDic[id] {
                        self.playSong(url: url)
                        self.currentSongId = id
                    } else {
                        //to do sth
                    }
                }
            } else {
                API.shared.getSongUrl(id: ids[currentIndex], completionHandler: { (url) in
                    self.urlDic[id] = url
                    self.playSong(url: url!)
                    self.currentSongId = id
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
//        guard isPlayingDidStart else { return }
        pause()
        self.currentIndex = getIndex(type: .Next)
        play()
    }
    
    func previous() {
//        guard isPlayingDidStart else { return }
        pause()
        self.currentIndex = getIndex(type: .Previous)
        play()
    }
    
    func replay() {
        self.streamer?.replay()
    }
    
    func pause() {
        self.isPlaying = false
        if self.streamer != nil {
            self.streamer?.pause()
        }
    }
    
    func resume() {
        self.isPlaying = true
        if self.streamer != nil {
            self.streamer?.play()
        }
    }
    
    func volumeUp() {
        if streamer != nil {
            volumeValue = volumeValue + 0.1 > 1 ? 1 : volumeValue + 0.1
            streamer?.setVolume(value: volumeValue)
        }
    }
    
    func volumeDown() {
        if streamer != nil {
            volumeValue = volumeValue - 0.1 < 0 ? 0 : volumeValue - 0.1
            streamer?.setVolume(value: volumeValue)
        }
    }
    
    func playSong(url:String) {
//        DispatchQueue.main.async {

            if self.streamer != nil {
                self.streamer?.stop()
                self.streamer?.releaseStreamer()
                self.streamer = nil
            }
            self.streamer = QSAudioStreamer.init(url: URL.init(string: url)!)
            self.streamer?.delegate = self
            self.streamer?.setVolume(value: self.volumeValue)
            
            self.isPlaying = true
//        }
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
        isPlayingDidStart = false
        if playMode == .OrderCycle || playMode == .ShuffleCycle {
            next()
        } else {
            replay()
        }
    }
    
    func playingDidStart() {
        isPlayingDidStart = true
    }
    
    func handleNetworkError(error: Error) {
//        print(error)
    }
    
    func handleWithKeyEvent(keyCode:Int32) {
        guard self.songList.count > 0 else { return }
        switch keyCode {
        case CMD_PLAY_PAUSE:
            guard songList.count > 0 else { return }
            if self.isPlaying {
                self.pause()
            } else {
                self.resume()
            }
        case CMD_PLAY_PREVIOUS.0, CMD_PLAY_PREVIOUS.1:
            self.previous()
        case CMD_PLAY_NEXT.0, CMD_PLAY_NEXT.1:
            self.next()
        case CMD_VOLUME_MINUS.0, CMD_VOLUME_MINUS.1:
            self.volumeDown()
        case CMD_VOLUME_ADD.0, CMD_VOLUME_ADD.1:
            self.volumeUp()
        case CMD_PLAYMODE_SINGLE:
            self.playMode = .SingleCycle
        case CMD_PLAYMODE_ORDER:
            self.playMode = .OrderCycle
        case CMD_PLAYMODE_SHUFFLE:
            self.playMode = .ShuffleCycle
        default:
            break
        }
    }
}
