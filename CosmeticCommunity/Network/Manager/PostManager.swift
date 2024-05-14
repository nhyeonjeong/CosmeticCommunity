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
    func checkWithHashTag(query: HashtagQuery) -> Observable<CheckPostModel> {
        return NetworkManager.shared.fetchAPI(type: CheckPostModel.self, router: Router.hashtag(query: query))
    }
    // 유저별 작성한 포스트
    func checkUserPosts(userId: String, query: CheckPostQuery) -> Observable<CheckPostModel> {
        return NetworkManager.shared.fetchAPI(type: CheckPostModel.self, router: Router.checkUserPosts(userId: userId, query: query))
    }
    
    func deletePost(postId: String) -> Observable<Void> {
        return NetworkManager.shared.noResponseFetchAPI(router: Router.deletePost(postId: postId))
    }
    // 포스트 수정
    func editPost(postId: String, query: PostQuery) -> Observable<PostModel> {
        return NetworkManager.shared.fetchAPI(type: PostModel.self, router: Router.editPost(postId: postId, query: query))
    }
    // 최근 본 포스트 유저디폴트에 저장
    func saveRecentPostsUserDefaults(postId: String) {
        let recentPosts = getRecentPostsUserDefaults()
        guard let posts = recentPosts else { // 하나도 저장되어있지 않았다면? 하나 저장
            do {
                let data = try JSONEncoder().encode([postId])
                UserDefaults.standard.setValue(data, forKey: UserDefaultKey.Post.recentPosts.rawValue)
            } catch {
                return
            }
            return
        }
        // posts는 유저디폴트에서 가져온 배열
        // 이미 본 포스트인지 확인
        var newArray = posts
        if newArray.contains(postId) { // 이미 봤다면 다시 앞으로 끌고오기
            let index = newArray.firstIndex { id in
                id == postId
            }
            newArray.remove(at: index ?? newArray.count - 1)
            newArray.insert(postId, at: 0) // 최신순으로 올리기
        
        } else {
            if posts.count > 20 {
                newArray.remove(at: posts.count-1) // 마지막 삭제
            }
            newArray.insert(postId, at: 0)
        }
//        print("📆 : \(newArray)")
        do {
            
            let data = try JSONEncoder().encode(newArray)
            UserDefaults.standard.setValue(data, forKey: UserDefaultKey.Post.recentPosts.rawValue)
        } catch {
            return
        }
    }
    
    func getRecentPostsUserDefaults() -> [String]? {
        if let postIds = UserDefaults.standard.data(forKey: UserDefaultKey.Post.recentPosts.rawValue) {
            do {
                let array = try JSONDecoder().decode([String].self, from: postIds)
//                print("🤔 \(array)")
                return array
            } catch {
                return nil
            }
        }
        return nil
    }
}
