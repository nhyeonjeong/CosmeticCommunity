//
//  String+Extension.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/05.
//

import Foundation

extension String {
    func dateFormat(_ date: Date) -> String {
        let format = DateFormatter()
        format.dateFormat = "yy.MM.dd" // 01월 -> 1월
        
        return format.string(from: date)
    }
    // ISO860
    func getDateFromISO8601() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        if let date = formatter.date(from: self) {
            print("👾\(date)")
            return dateFormat(date)
            
        } else {
            return self
        }
    }
}

