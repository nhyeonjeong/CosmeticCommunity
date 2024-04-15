//
//  NetworkManager.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/04/14.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire // 알라모파이어 사용

// struct vs class
final class NetworkManager {
    static let shared = NetworkManager()
    
    private init() { }
    
    func fetchAPI<T: Decodable>(type: T.Type, router: Router) -> Observable<T> {
        return Observable<T>.create { observer in
            var urlRequest: URLRequest
            do {
                urlRequest = try router.asURLRequest()
            } catch {
                observer.onError(APIError.invalidURLError_444)
                return Disposables.create()
            }
            AF.request(urlRequest)
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let success):
                        print(success)
                        observer.onNext(success)
                        observer.onCompleted()
                        return
                    case .failure(_):
                        switch response.response?.statusCode {
                        case 420:
                            observer.onError(APIError.sesacKeyError_420)
                        case 400:
                            observer.onError(APIError.requestError_400)
                        case 401:
                            observer.onError(APIError.invalidUserError_401)
                        case .none:
                            return
                        case .some(_):
                            return
                        }
                        return
                    }
                }
            return Disposables.create()
        }
    }
}

