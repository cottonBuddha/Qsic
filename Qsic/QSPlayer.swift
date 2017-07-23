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
    var player : AVAudioPlayer?
    
    private init() {
        
    }
    

}
