//
//  ChattingManager.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/31.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

class ChattingManager {
    // 채팅룸만들기
    func makeChattingRoomId(query: ChattingRoomQuery) -> Observable<ChattingRoomModel> {
        return NetworkManager.shared.fetchAPI(type: ChattingRoomModel.self, router: Router.makeChattingRoom(query: query))
    }
}
