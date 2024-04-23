//
//  Like.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/21.
//

import Foundation
import RxSwift
import RxCocoa

final class LikeManager {
    // 좋아요/취소 상태 바꾸기
    func changeLikeStatus(_ data: LikeQuery, postId: String) -> Observable<LikeModel> {
        return NetworkManager.shared.fetchAPI(type: LikeModel.self, router: Router.likeStatus(query: data, postId: postId))
    }
    // 내가 좋아요한 포스터 가져오기
    func getMyLikedPosts() -> Observable<CheckPostModel> {
        return NetworkManager.shared.fetchAPI(type: CheckPostModel.self, router: Router.myLikedPosts)
    }
}
