//
//  main.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/7/7.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation

let argCount = CommandLine.argc
let arguments = CommandLine.arguments

if 1 == argCount {
    QSMusicController().start()
} else {
    let cm = arguments[1]
    if "-v" == cm || "--version" == cm {
        print("v0.1.1")
    } else if "-h" == cm || "--help" == cm {
        let basicOperation =
        """
        基本操作：
            上下页请按： ←、→
            上下项请按： ↑、↓
            选中项请按：↵
            返回上级菜单请按： /
            登录请在首页按：d (仅支持手机号登录)
            退出请按：q
            更多操作请前往[首页-帮助]
        """
        print(basicOperation)
    } else {
        print("I have no idea of this order! Try -h or -v")
    }
}



