//
//  ScrollViewKeyboard.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/18.
//

import Foundation

protocol ScrollViewKeyboard {
    var isExpand: Bool { get set }
    func keyboardAppear(notification: NSNotification)
    func keyboardDisappear(notification: NSNotification)
}

