//
//  QSWidget.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/7/8.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
import Darwin.ncurses

class QSWidget {

    var startX : Int
    var startY : Int
    var width : Int
    var height : Int
    
    var window : OpaquePointer?
    
    var focused : Bool
    
//    var bgColor : WidgetUIColor

    public init(startX:Int, startY:Int, width:Int, height:Int) {
        self.startX = startX
        self.startY = startY
        self.width = width
        self.height = height
        self.focused = false
    }
    
    internal func initWidgetOnSuperwidget(superwidget:QSWidget) {
        wmove(superwidget.window, 0, 0)
        self.startX = superwidget.startX + self.startX
        self.startY = superwidget.startY + self.startY
        if self.width == Int(COLS) {
            self.width = superwidget.width - self.startX
        }
        self.window = subwin(superwidget.window, Int32(self.height), Int32(self.width), Int32(self.startY), Int32(self.startX))
        keypad(self.window, true)
//        wborder(self.window, 0, 0, 0, 0, 0, 0, 0, 0)

    }
    
    public func drawWidget() {
        guard self.window != nil else {
            return
        }

        wrefresh(self.window)
    }
    
    public func resize() {
        
    }
}

extension QSWidget {
    
    public func addSubWidget(widget:QSWidget) {
        
        widget.initWidgetOnSuperwidget(superwidget: self)
        widget.drawWidget()
    }
    
    public func removeFromSuperwidget() {
        
    }

    public func insertSubwidget() {
        
    }
    
    public func bringSubwidgetToFront() {
        
    }
    
}


