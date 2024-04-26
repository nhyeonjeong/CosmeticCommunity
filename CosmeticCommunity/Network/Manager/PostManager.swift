//
//  PostManager.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/17.
//

import Foundation
import RxSwift
import RxCocoa

final class PostManager {
    
    func uploadPostImages(_ items: [Data]?) -> Observable<PostImageStingModel> {
        return NetworkManager.shared.dataAPI(type: PostImageStingModel.self, router: Router.uploadPostImage(query: items))
    }
    func uploadPost(_ data: PostQuery) -> Observable<PostModel> {
        return NetworkManager.shared.fetchAPI(type: PostModel.self, router: Router.upload(query: data))
    }
    // 포스트 조회
    func checkPosts(_ data: CheckPostQuery) -> Observable<CheckPostModel> {
        return NetworkManager.shared.fetchAPI(type: CheckPostModel.self, router: Router.checkPosts(query: data))
    }
    // 특정 포스트 조회
    func checkSpecificPost(postId: String) -> Observable<PostModel> {
        return NetworkManager.shared.fetchAPI(type: PostModel.self, router: Router.checkSpecificPost(postId: postId))
    }
    // 유저별 작성한 포스트
    func checkUserPosts(userId: String) -> Observable<CheckPostModel> {
        return NetworkManager.shared.fetchAPI(type: CheckPostModel.self, router: Router.checkUserPosts(userId: userId))
    }
    
    func deletePost(postId: String) -> Observable<Void> {
        return NetworkManager.shared.deleteFetchAPI(router: Router.deletePost(postId: postId))
    }
    
    // 최근 본 포스트 유저디폴트에 저장
    func saveRecentPostsUserDeaults(postId: String) {
        let recentPosts = UserDefaults.standard.value(forKey: UserDefaultKey.Post.recentPosts.rawValue)
        if let posts = recentPosts as? [String] {
            var newArray = posts
            if posts.count > 20 {
                newArray.remove(at: posts.count-1) // 마지막 삭제
            }
            newArray.append(postId)
            UserDefaults.standard.setValue(newArray, forKey: UserDefaultKey.Post.recentPosts.rawValue)
        }
    }
}
