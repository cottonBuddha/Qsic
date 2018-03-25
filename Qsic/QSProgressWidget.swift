//
//  QSProgressWidget.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/7/7.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
enum ProgressType: Int {
    case MKBar
    case Dancer
    case FireFly
    case Ing
}

class QSProgressWidget: QSWidget  {
    
    private var progressType: ProgressType!
    
    private let bars = ["-","\\","|","/"]
    private let faces = ["＼（￣︶￣）／","╭（￣▽￣）╭"]
    private let ings = ["",".","..","..."]
    private let fireFlies = ["⠁","⠂","⠄","⡀","⢀","⠠","⠐","⠈"]

    private var timer: Timer?
    var isLoading: Bool = false

    convenience init(startX:Int, startY:Int, type:ProgressType) {
        var width = 1
        switch type {
        case .MKBar , .FireFly:
            width = 1
        case .Dancer:
            width = 14
        case .Ing:
            width = 4
        }
        self.init(startX: startX, startY: startY, width: width, height: 1)
        progressType = type
    }
    
    override init(startX: Int, startY: Int, width: Int, height: Int) {
        super.init(startX: startX, startY: startY, width: width, height: height)
    }
    
    override func drawWidget() {
        super.drawWidget()
        wrefresh(self.window)
    }
    
    func load() {
        DispatchQueue.main.async {
            if self.isLoading { return }
            self.isLoading = true
            self.play(type: self.progressType)
        }
    }
    
    func end() {
        self.isLoading = false
        self.timer?.invalidate()
        self.timer = nil
        self.eraseSelf()
    }
    
    func pause() {
        self.isLoading = false
        let type:ProgressType = self.progressType
        var item = "[PAUSE]"
        switch type {
        case .Dancer:
            item = "╭(￣３￣)╯"
        default: break
            
        }
        if self.timer != nil {
            self.end()
        }
        self.eraseSelf()
        mvwaddstr(self.window, 0, 0, item)
        wrefresh(self.window)
    }

    private func play(type:ProgressType) {
        
        var timeInterval: TimeInterval = 1
        var items: [String] = []
        switch type {
        case .MKBar:
            timeInterval = 0.13
            items = bars
        case .Dancer:
            timeInterval = 0.5
            items = faces
        case .FireFly:
            timeInterval = 0.08
            items = fireFlies
        case .Ing:
            timeInterval = 0.4
            items = ings
        }
        
        var i = 0

        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer) in
            curs_set(0)
            self.eraseSelf()
            mvwaddstr(self.window, 0, 0, items[i])
            wrefresh(self.window)
            i = i + 1
            
            if i > items.count - 1 {
                i = 0
            }
        })
    }
}
