//
//  QSMusicController.swift
//  Qsic
//
//  Created by 江齐松 on 2017/7/12.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
import Darwin

class QSMusicController {
    var mainwin : QSMainWindow = QSMainWindow.init()
    
    private var ch : Character?
    
    private var ic : Int32?
    
    
    func start() {
        
        self.listenToInstructions()
        mainwin.endWin()
    }
    
    func setUpWidgets() {
        
    }
    
    func listenToInstructions() {
        ic = getch()
        ch  = Character(UnicodeScalar(UInt32(ic!))!)
        
        while ch != "q" {
            
            switch Int32(ic!) {
                
            case KEY_RIGHT :
                print("s")
                
                
            case KEY_LEFT :
                print("s")

                
                
            case KEY_UP :
                print("s")

                
                
            case KEY_DOWN :
                print("s")

            case KEY_Q_LOW :
                print("m")
                
            default :
                break
            }
            
            ic = UInt32(getch())
            ch  = Character(UnicodeScalar(ic!)!)
            
        }

    }
    
}
