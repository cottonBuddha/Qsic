//
//  config.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/8/27.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
import Darwin.ncurses

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

public let KEY_L_ANGLE_EN: Int32 = 44
public let KEY_R_ANGLE_EN: Int32 = 46
public let KEY_L_ANGLE_ZH: Int32 = 140
public let KEY_R_ANGLE_ZH: Int32 = 130

public let EN_L_C_BRACE: Int32 = 91
public let EN_R_C_BRACE: Int32 = 93
public let ZH_L_C_BRACE: Int32 = 144
public let ZH_R_C_BRACE: Int32 = 145

public let KEY_SLASH_EN: Int32 = 47
public let KEY_SLASH_ZH: Int32 = 129

public let KEY_NUMBER_ONE: Int32 = 49
public let KEY_NUMBER_TWO: Int32 = 50
public let KEY_NUMBER_THREE: Int32 = 51

public let KEY_ENTER: Int32 = 10
public let KEY_SPACE: Int32 = 32
public let KEY_COMMA: Int32 = 39
public let KEY_DOT: Int32 = 46


/**
 向上移动
 */public let CMD_UP = KEY_UP

/**
 向下移动
 */public let CMD_DOWN = KEY_DOWN

/**
 上一页
 */public let CMD_LEFT = KEY_LEFT

/**
 下一页
 */public let CMD_RIGHT = KEY_RIGHT

/**
 选中
 */public let CMD_ENTER = KEY_ENTER

/**
 退出
 */public let CMD_QUIT = KEY_Q_LOW

/**
 退出且退出登录
 */public let CMD_QUIT_LOGOUT = KEY_W_LOW

/**
 返回上一级菜单
 */public let CMD_BACK = (KEY_SLASH_ZH,KEY_SLASH_EN)

/**
 播放/暂停
 */public let CMD_PLAY_PAUSE = KEY_SPACE

/**
 下一首
 */public let CMD_PLAY_NEXT = (KEY_R_ANGLE_EN,KEY_R_ANGLE_ZH)

/**
 上一首
 */public let CMD_PLAY_PREVIOUS = (KEY_L_ANGLE_EN,KEY_L_ANGLE_ZH)

/**
 音量+
 */public let CMD_VOLUME_ADD = (EN_R_C_BRACE,ZH_R_C_BRACE)

/**
 音量-
 */public let CMD_VOLUME_MINUS = (EN_L_C_BRACE,ZH_L_C_BRACE)

/**
 添加到收藏
 */public let CMD_ADD_LIKE = KEY_A_LOW

/**
 搜索
 */public let CMD_SEARCH = KEY_S_LOW

/**
 登录
 */public let CMD_LOGIN = KEY_D_LOW

/**
 当前播放列表
 */public let CMD_PLAY_LIST = KEY_F_LOW

/**
 打开GitHub
 */public let CMD_GITHUB = KEY_G_LOW

/**
 隐藏╭(￣３￣)╯播放指示
 */public let CMD_HIDE_DANCER = KEY_H_LOW

/**
 单曲循环
 */public let CMD_PLAYMODE_SINGLE = KEY_NUMBER_ONE

/**
 顺序播放
 */public let CMD_PLAYMODE_ORDER = KEY_NUMBER_TWO

/**
 随机播放
 */public let CMD_PLAYMODE_SHUFFLE = KEY_NUMBER_THREE


/**
 相关设置的key
 */
public let UD_POP_HINT = "UD_POP_HINT"
public let UD_HIDE_DANCER = "UD_HIDE_DANCER"
public let UD_USER_NICKNAME = "UD_USER_NICKNAME"
public let UD_USER_ID = "UD_USER_ID"

