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
            var urlRequest: URLRequest
            do {
                urlRequest = try router.asURLRequest()
//                print("urlRequest: ", urlRequest)
            } catch {
                observer.onError(APIError.invalidURLError_444)
                return Disposables.create()
            }
            /*
            AF.request(urlRequest)
                .responseString { response in
                    print("responseString : \(response)")
                }

*/
            
              AF.request(urlRequest)
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
                            print("error ----------> none Error")
                            return
                        case .some(_):
                            print("error ---------------> some Error")
                            return
                        }
                        print("time out..?")
                        return
                    }
                }
             
            return Disposables.create()
 
        }
    }
}

extension NetworkManager {
    func dataAPI<T: Decodable>(type: T.Type, router: Router, completionHandler: @escaping ((T) -> Void) = { _ in }) -> Observable<T> {
        return Observable<T>.create { observer in
/*
            AF.upload(multipartFormData: { multipartFormData in
                // 헤더키는 withname에 해당한다 -> files
                // fileName -
                guard let datas = router.multipartBody else {
                    return
                }
                for data in datas {
                    multipartFormData.append(data, withName: ParameterKey.files.rawValue, fileName: "\(Date())-\(Int.random(in: 1...1000))", mimeType: "image/png")
                }


            }, to: router.baseURL+router.path, headers: router.headers).responseString { data in
                print("responseString", data)
            }
 */
             
            AF.upload(multipartFormData: { multipartFormData in
                // 헤더키는 withname에 해당한다 -> files
                // fileName -
                guard let datas = router.multipartBody else {
                    return
                }
                for data in datas {
                    let date = Calendar.current.component(.day, from: Date())
                    multipartFormData.append(data, withName: ParameterKey.files.rawValue, fileName: "\(date)_\(Int.random(in: 1...1000))", mimeType: "image/png")
                }


            }, to: router.baseURL+router.path, headers: router.headers) // 어떤 헤더가 들어갈지 명시해줘야
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let success):
//                    print(success)
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
                        print("error ----------> none Error")
                        return
                    case .some(_):
                        print("error ---------------> some Error")
                        return
                    }
                    print("time out..?")
                    return
                }
            }
              
            return Disposables.create()
        }
    }
}

