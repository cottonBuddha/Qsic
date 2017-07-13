//
//  QSNavigator.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/7/13.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
class QSNavigator {
    
    var rootWidget : QSWidget?
    var widgets : [QSWidget] = []
    var currentWidget : QSWidget?
    weak var mainWin : QSMainWindow?
    
    public init(rootWidget:QSWidget) {
        
        self.rootWidget = rootWidget
        self.currentWidget = rootWidget
    }
    
    func pushTo(_ widget:QSWidget) {
        self.mainWin?.addSubWidget(widget: widget)
        widgets.append(widget)
        self.currentWidget = widget
    }
    
    func pop() {
        widgets.last?.destroyWindow()
        widgets.removeLast()
        self.currentWidget = self.rootWidget!
        self.mainWin?.addSubWidget(widget: self.rootWidget!)
        //有add就有remove，补完remove方法
    }
    
    
    
}
