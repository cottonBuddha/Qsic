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
    
    weak var superWidget : QSWidget?
    var subWidgets : [QSWidget]?
    
    //wclear()函数在item上会留下之前屏幕的记录，所以只能用空白字符串手动清除
    lazy var eraseLineStr : String = {
        var str = ""
        for i in (0..<self.width) {
            str.append(" ")
        }
        return str
    }()
    
    public init(startX:Int, startY:Int, width:Int, height:Int) {
        self.startX = startX
        self.startY = startY
        self.width = width
        self.height = height
    }
    
    internal func initWidgetOnSuperwidget(superwidget:QSWidget) {
        wmove(superwidget.window, 0, 0)
        self.startX = superwidget.startX + self.startX
        self.startY = superwidget.startY + self.startY
        if self.width == Int(COLS) {
            self.width = superwidget.width - self.startX
        }
        self.window = subwin(superwidget.window, Int32(self.height), Int32(self.width), Int32(self.startY), Int32(self.startX))
        //        wborder(self.window, 0, 0, 0, 0, 0, 0, 0, 0)
        
    }
    
    public func drawWidget() {
        guard self.window != nil else {
            return
        }
        
        wrefresh(self.window)
    }
    
    public func resize() {
        
        //        resizeterm(Int32, Int32)
    }
    
    public func addSubWidget(widget:QSWidget) {
        widget.superWidget = self
        self.subWidgets?.append(widget)
        widget.initWidgetOnSuperwidget(superwidget: self)
        widget.drawWidget()
        widget.subWidgets?.forEach({ (widget) in
            widget.addSubWidget(widget: widget)
        })
        
    }
    
    public func removeSubWidget(widget:QSWidget) {
        if let index = self.subWidgets?.index(of: widget) {
            self.subWidgets?.remove(at: index)
            widget.destroyWindow()
        }
    }
    
    public func removeSubWidgets() {
        self.subWidgets?.removeAll()
        self.drawWidget()
    }
    
    public func destroyWindow() {
        delwin(self.window)
    }
    
    public func handleWithKeyEvent(keyCode:Int32) {
        
    }
    
}

extension QSWidget : Equatable {
    
    public static func ==(lhs: QSWidget, rhs: QSWidget) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
