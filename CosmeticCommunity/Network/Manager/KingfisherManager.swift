//
//  KingfisherManager.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/20.
//

import Foundation
import Kingfisher

final class KingfisherManager {
    let modifier = AnyModifier { request in
        var r = request
        r.method = .get
        r.headers = [HTTPHeader.authorization.rawValue: MemberManger.shared.getAccessToken() ?? "",
                     HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                    HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]
        return r
    }
    
    func getImage(path: String?, completionHandler: (URL?) -> Void) {
        if let path, let url = URL(string: "\(APIKey.baseURL.rawValue)v1/" + path) {
            completionHandler(url)
        } else {
            completionHandler(nil)
        }

        
    }
}
