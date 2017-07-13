//
//  QSNavigator.swift
//  Qsic
//
//  Created by 江齐松 on 2017/7/13.
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

    }
    
    func pushTo(_ widget:QSWidget) {
        
        widgets.append(widget)
        self.currentWidget = widget
    }
    
    func pop() {
        widgets.removeLast()
//        self.removeSubWidget(widget: currentWidget!)
    }
    
    
    
}
