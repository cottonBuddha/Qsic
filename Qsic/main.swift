//
//  main.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/7/7.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
import AVFoundation

public var KEY_A_LOW: Int32 = 97
public var KEY_B_LOW: Int32 = 98
public var KEY_C_LOW: Int32 = 99
public var KEY_D_LOW: Int32 = 100
public var KEY_E_LOW: Int32 = 101
public var KEY_F_LOW: Int32 = 102
public var KEY_G_LOW: Int32 = 103
public var KEY_H_LOW: Int32 = 104
public var KEY_I_LOW: Int32 = 105
public var KEY_J_LOW: Int32 = 106
public var KEY_K_LOW: Int32 = 107
public var KEY_L_LOW: Int32 = 108
public var KEY_M_LOW: Int32 = 109
public var KEY_N_LOW: Int32 = 110
public var KEY_O_LOW: Int32 = 111
public var KEY_P_LOW: Int32 = 112
public var KEY_Q_LOW: Int32 = 113
public var KEY_R_LOW: Int32 = 114
public var KEY_S_LOW: Int32 = 115
public var KEY_T_LOW: Int32 = 116
public var KEY_U_LOW: Int32 = 117
public var KEY_V_LOW: Int32 = 118
public var KEY_W_LOW: Int32 = 119
public var KEY_X_LOW: Int32 = 120
public var KEY_Y_LOW: Int32 = 121
public var KEY_Z_LOW: Int32 = 122
public var KEY_L_C_BRACE: Int32 = 123
public var KEY_R_C_BRACE: Int32 = 124

API.shared.GET(urlStr: "http://music.163.com/discover/toplist?id=180106", params: nil) { (data, response, error) in
//    let models = generateSongModels(data: data!)
//    print(models)
    let str = String.init(data: data!, encoding: String.Encoding.utf8)
    let result = str?.matchRegExp("/song\\?id=(\\d+)")
    print(result ?? "")
    
//    if let model = models.first {
//        print(model.name)
//        print(model.id)
//        print(model.mp3Url!)
//    }
}

//let url = "http://m2.music.126.net/RMJR7wDullRqppBk8dhLow==/3435973841155597.mp3"
//let player = try AVAudioPlayer(contentsOf: URL.init(string: url)!)
//
//player.play()

//API.shared.login(username: "", password: "")

QSMusicController().start()






