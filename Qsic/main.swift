//
//  main.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/7/7.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation

//QSMusicController().start()

API.shared.songListDetail(listId: "1992534206") { models in

    print(models)
}

RunLoop.main.run()


