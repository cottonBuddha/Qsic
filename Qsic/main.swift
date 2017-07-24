//
//  main.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/7/7.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
import AVFoundation

public let KEY_COMMA: Int32 = 39
public let KEY_DOT: Int32 = 46
public let KEY_SLASH: Int32 = 47
public let KEY_A_LOW: Int32 = 97
public let KEY_B_LOW: Int32 = 98
public let KEY_C_LOW: Int32 = 99
public let KEY_D_LOW: Int32 = 100
public let KEY_E_LOW: Int32 = 101
public let KEY_F_LOW: Int32 = 102
public let KEY_G_LOW: Int32 = 103
public let KEY_H_LOW: Int32 = 104
public let KEY_I_LOW: Int32 = 105
public let KEY_J_LOW: Int32 = 106
public let KEY_K_LOW: Int32 = 107
public let KEY_L_LOW: Int32 = 108
public let KEY_M_LOW: Int32 = 109
public let KEY_N_LOW: Int32 = 110
public let KEY_O_LOW: Int32 = 111
public let KEY_P_LOW: Int32 = 112
public let KEY_Q_LOW: Int32 = 113
public let KEY_R_LOW: Int32 = 114
public let KEY_S_LOW: Int32 = 115
public let KEY_T_LOW: Int32 = 116
public let KEY_U_LOW: Int32 = 117
public let KEY_V_LOW: Int32 = 118
public let KEY_W_LOW: Int32 = 119
public let KEY_X_LOW: Int32 = 120
public let KEY_Y_LOW: Int32 = 121
public let KEY_Z_LOW: Int32 = 122
public let KEY_L_C_BRACE: Int32 = 123
public let KEY_R_C_BRACE: Int32 = 124


//API.shared.GET(urlStr: "http://music.163.com/discover/toplist?id=180106", params: nil) { (data, response, error) in
//
//    let str = String.init(data: data!, encoding: String.Encoding.utf8)
//    let result = str?.matchRegExp("/song\\?id=(\\d+)")
//    print(result ?? "")
//    
//}

//let A_ASCII = UnicodeScalar("⠋")
//print(A_ASCII)

API.shared.songDetail(rankingUrl: "http://music.163.com/discover/toplist?id=180106") { (songs) in
    print(songs)
}



//let url = "http://m2.music.126.net/RMJR7wDullRqppBk8dhLow==/3435973841155597.mp3"
//let player = try AVAudioPlayer(contentsOf: URL.init(string: url)!)
//
//player.play()

//API.shared.login(username: "", password: "")

//API.shared.rankings(completionHandler: { (rankings) in
//    let newDic = rankings.split(num: 10)
//    print(newDic)
//})

QSMusicController().start()






