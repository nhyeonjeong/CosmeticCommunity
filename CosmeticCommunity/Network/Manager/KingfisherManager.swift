//
//  KingfisherManager.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/20.
//

import Foundation
import Kingfisher

extension KingfisherManager {
    var modifier: AnyModifier {
        AnyModifier { request in
            var r = request
            r.method = .get
            r.headers = [HTTPHeader.authorization.rawValue: UserManager.shared.getAccessToken() ?? "",
                         HTTPHeader.contentType.rawValue: HTTPHeader.json.rawValue,
                         HTTPHeader.sesacKey.rawValue: APIKey.sesacKey.rawValue]
            return r
        }
    }
    func getImageURL(path: String?, completionHandler: (URL?) -> Void) {
        if let path, let url = URL(string: "\(APIKey.baseURL.rawValue)v1/" + path) {
            completionHandler(url)
        } else {
            completionHandler(nil)
        }
    }
    func getImageData(path: String?, completionHandler: @escaping (KFCrossPlatformImage) -> Void) {
        if let path, let url = URL(string: "\(APIKey.baseURL.rawValue)v1/" + path) {
            retrieveImage(with: url) { response in
                switch response {
                case .success(let value):
                    completionHandler(value.image)
                case .failure(_):
                    completionHandler(Constants.Image.defulatProfileImage)
                }
            }
        } else {
            completionHandler(Constants.Image.defulatProfileImage)
        }
    }
}

