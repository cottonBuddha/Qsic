//
//  QSWidget.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/7/8.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
import Darwin.ncurses

class QSWidget : OperatorationProtocol{

    var startX : Int
    var startY : Int
    var width : Int
    var height : Int
    
    var window : OpaquePointer?
    
    var focused : Bool
    
    weak var superWidget : QSWidget?
    var subWidgets : [QSWidget]?
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
    
    private func destroyWindow() {
        delwin(self.window)
    }

}

extension QSWidget : Equatable {
    
    public static func ==(lhs: QSWidget, rhs: QSWidget) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}



protocol OperatorationProtocol {
    func up();
    
    func down();
    
    func left();
    
    func right();
    
    func enter();
}

extension OperatorationProtocol {
    
    func up() {
        
    }
    
    func down() {
        
    }
    
    func left() {
        
    }
    
    func right() {
        
    }
    
    func enter() {
        
    }
}
