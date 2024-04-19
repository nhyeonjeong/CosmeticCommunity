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
        return NetworkManager.shared.fetchAPI(type: PostModel.self, router: Router.upload(query: data, accessToken: MemberManger.shared.getAccessToken() ?? "")) // accessToken이 없다면 ""...
    }
}
