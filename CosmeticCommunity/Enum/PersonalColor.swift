//
//  PersonalColor.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/20.
//

import UIKit

enum PersonalColor: String, CaseIterable {
    case none = "" // 회원가입시 입력하지 않았거나 잘못가져왔을 때
    case spring = "봄웜"
    case summer = "여름쿨"
    case fall = "가을웜"
    case winter = "겨울쿨"

    
    static var personalCases: [PersonalColor] {
        var cases = PersonalColor.allCases
        cases.removeFirst()
        return cases
    }
    var backgroundColor: UIColor {
        switch self {
        case .spring:
            return .springBackground
        case .summer:
            return .summerBackground
        case .fall:
            return .fallBackground
        case .winter:
            return .winterBackground
        case .none:
            return .white
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .spring:
            return .black
        case .summer:
            return .black
        case .fall:
            return .white
        case .winter:
            return .white
        case .none:
            return Constants.Color.text
        }
    }
}
