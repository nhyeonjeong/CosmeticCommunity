//
//  UserDefaultManager.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/01.
//

import Foundation

final class UserDefaultManager {
    static let shared = UserDefaultManager()
    private init() { }
    func saveRecentSearch(_ text: String) {
        let list = getRecentSearch()
        if var newList = list {
            // 이미 검색했던 거라면
            if let index = newList.firstIndex(where: { list in
                list.contains(text)
            }) {
                newList.remove(at: index)
            }
            if newList.count > 20 { // 20개까지만 저장
                newList.removeLast()
            }
            newList.insert(text, at: 0)
            UserDefaults.standard.setValue(newList, forKey: UserDefaultKey.Search.recentSearchText.rawValue)
        } else {
            UserDefaults.standard.setValue([text], forKey: UserDefaultKey.Search.recentSearchText.rawValue)
        }
    }
    
    func getRecentSearch() -> [String]? {
        let list = UserDefaults.standard.value(forKey: UserDefaultKey.Search.recentSearchText.rawValue)
        guard let list = list as? [String] else {
            return nil
        }
        return list
    }
}
