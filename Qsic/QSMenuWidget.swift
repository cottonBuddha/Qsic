//
//  QSMenuWidget.swift
//  Qsic
//
//  Created by cottonBuddha on 2017/7/7.
//  Copyright © 2017年 cottonBuddha. All rights reserved.
//

import Foundation
import Darwin

class QSMenuWidget: QSWidget,KeyEventProtocol {

    var title : String = ""
    var type : Int = 0
    var selected : ((_ type:Int, _ selectedItem: MenuItemModel) -> ())?
    var progress : QSProgressWidget?
    private var currentPageIndex : Int = 0
    private var currentRowIndex : Int = 0
    private var splitItems : [[MenuItemModel]] = []
    
    private var currentItemCode : Int = 0 {
        didSet {
            let lastCode = dataModel.items.count - 1
            currentItemCode = currentItemCode > lastCode ? lastCode : (currentItemCode < 0 ? 0 : currentItemCode)
            dataModel.currentItemCode = currentItemCode
            self.currentRowIndex = (dataModel.currentItemCode) % dataModel.rowsNum
            self.currentPageIndex = (dataModel.currentItemCode) / dataModel.rowsNum
        }
    }
    
    var dataModel : QSMenuModel! {
        didSet {
            title = dataModel.title
            type = dataModel.type
            currentItemCode = dataModel.currentItemCode
            splitItems = dataModel.items.split(num: dataModel.rowsNum)
        }
    }
    
    public init(startX: Int, startY: Int, width: Int, dataModel: QSMenuModel, selected: ((_ type:Int, _ selectedItem: MenuItemModel) -> ())?) {
        self.selected = selected
        super.init(startX: startX, startY: startY, width: width, height: dataModel.rowsNum)
        self.setUpMenu(dataModel: dataModel)
        NotificationCenter.default.addObserver(self, selector: #selector(QSMenuWidget.handleWithKeyEvent(keyEventNoti:)), name:Notification.Name(rawValue: kNotificationKeyEvent), object: nil)
    }
    
    private func setUpMenu(dataModel:QSMenuModel) {
        self.dataModel = dataModel
    }
    
    override func drawWidget() {
        super.drawWidget()
        self.drawMenu()
        wrefresh(self.window)
    }

    private func drawMenu() {
        for index in 0..<self.splitItems[self.currentPageIndex].count {
//            let bcolor = init_color(0, 1, 0, 0)
//            init_pair(1, Int16(COLOR_CYAN), Int16(use_default_colors()))
            mvwaddstr(self.window, Int32(index), 0, splitItems[self.currentPageIndex][index].title)
            mvwchgat(self.window, Int32(self.currentRowIndex), 0, -1, 2097152, 1, nil)
        }
        
        if (self.dataModel.items.count == 0) || (self.dataModel == nil) {
            mvwaddstr(self.window, 0, 0, "什么都没有~ (°ー°〃)")
        }
    }
    
    func presentMenuWithModel(menuModel:QSMenuModel) {
        self.eraseSelf()
        self.setUpMenu(dataModel: menuModel)
        self.currentItemCode = menuModel.currentItemCode
        self.drawWidget()
    }
    
    func refreshMenu() {
        self.eraseSelf()
        self.drawWidget()
    }
    
    @objc func handleWithKeyEvent(keyEventNoti: Notification) {
        if progress != nil, progress!.isLoading {
            return
        }
        let keyCode = keyEventNoti.object as! Int32
        switch keyCode {
        case CMD_UP:
            self.currentItemCode = self.currentItemCode - 1
            self.refreshMenu()
        case CMD_DOWN:
            self.currentItemCode = self.currentItemCode + 1
            self.refreshMenu()
        case CMD_LEFT:
            let prePageIndex = self.currentPageIndex - 1
            self.currentItemCode = prePageIndex * self.dataModel.rowsNum
            self.refreshMenu()
        case CMD_RIGHT:
            let nextPageIndex = self.currentPageIndex + 1
            self.currentItemCode = nextPageIndex * self.dataModel.rowsNum
            self.refreshMenu()
        case CMD_ENTER:
            if self.selected != nil && self.dataModel != nil && self.dataModel.items.count != 0 {
                self.selected!(self.type, self.dataModel.items[self.currentItemCode])
            }
//        case CMD_PLAY_PREVIOUS.0, CMD_PLAY_PREVIOUS.1:
//            if self.type == MenuType.Song.rawValue {
//                self.currentItemCode = self.currentItemCode - 1
//                self.refreshMenu()
//            }
//        case CMD_PLAY_NEXT.0, CMD_PLAY_NEXT.1:
//            if self.type == MenuType.Song.rawValue {
//                self.currentItemCode = self.currentItemCode + 1
//                self.refreshMenu()
//            }
        default:
          break
        }
    }
    
    func showProgress() {
        guard progress == nil else { return }
        let startX = self.dataModel.items[self.currentItemCode].title.lengthInCurses()
        progress = QSProgressWidget.init(startX: startX, startY: self.currentRowIndex, type: .FireFly)
        self.addSubWidget(widget: progress!)
        progress!.load()
    }
    
    func hideProgress() {
        guard progress != nil else { return }
        progress!.end()
        self.removeSubWidget(widget: progress!)
        progress = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
