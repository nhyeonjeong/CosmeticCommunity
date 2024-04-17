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
    
    func fetchAPI<T: Decodable>(type: T.Type, router: Router, completionHandler: @escaping ((T) -> Void) = { _ in }) -> Observable<T> {
        return Observable<T>.create { observer in
//            var urlRequest: URLRequest
//            do {
//                urlRequest = try router.asURLRequest()
//            } catch {
//                observer.onError(APIError.invalidURLError_444)
//                return Disposables.create()
//            }
            
//            AF.request(router.path, method: router.method, parameters: router.parameters, encoding: JSONEncoding(), headers: router.header).responseString { data in
//                print(data)
//            }
             
            
            AF.request(router.path, method: router.method, parameters: router.parameters, encoding: JSONEncoding(), headers: router.header)
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let success):
                        print(success)
                        completionHandler(success) // 성공시 실행할 게 있다면 실행하기
                        observer.onNext(success)
                        observer.onCompleted()
                        return
                    case .failure(let failure):
                        print("failure: \(failure)")
                        switch response.response?.statusCode {
                        case 420:
                            observer.onError(APIError.sesacKeyError_420)
                        case 400:
                            observer.onError(APIError.requestError_400)
                        case 401:
                            observer.onError(APIError.invalidUserError_401)
                        case 418:
                            observer.onError(APIError.refreshTokenExpired_418)
                        case 419:
                            observer.onError(APIError.accessTokenExpired_419)
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

