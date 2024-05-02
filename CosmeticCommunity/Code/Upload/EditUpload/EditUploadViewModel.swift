//
//  EditViewModel.swift
//  CosmeticCommunity
//
//  Created by 남현정 on 2024/05/02.
//

import Foundation
import RxSwift
import RxCocoa
    
final class EditUploadViewModel: InputOutput {
    var postId: String?
    let postManager = PostManager()
    var disposeBag: RxSwift.DisposeBag = DisposeBag()
    var outputLoginView: RxRelay.PublishRelay<Void> = PublishRelay<Void>()
    var photos: [NSItemProviderReading] = [] // 선택한 사진 컬렉션뷰에 그리는 용도
    var photoString = BehaviorSubject<[String]>(value: [])
    let personalCases = PersonalColor.personalCases
    
    struct Input {
        let inputTitleString: ControlProperty<String?>
        let inputPersonalColor: BehaviorSubject<PersonalColor>
        let inputContentString: ControlProperty<String?>
        let inputEditButton: PublishSubject<Void>
        let inputUploadImagesTrigger: PublishSubject<Void>
        let inputEditTrigger: PublishSubject<Void>
        let inputSelectPhotos: PublishSubject<Void>
        let inputHashTags: ControlProperty<String?>
        // 사진의 X버튼
        let inputXbuttonTrigger: PublishSubject<Int>
    }
    struct Output {
        // 글쓰기를 할 수 있는지 유효성 검사
        let outputValid: Driver<(Bool, String)>
        let outputEditTrigger: PublishSubject<PostModel?>
        let outputLoginView: PublishRelay<Void>
        let outputPhotoItems: Driver<[NSItemProviderReading]>
    }
    
    func transform(input: Input) -> Output {
        let outputValid = BehaviorRelay<(Bool, String)>(value: (false, ""))
        let outputEditTrigger = PublishSubject<PostModel?>()
        let outputPhotoItems = PublishRelay<[NSItemProviderReading]>()
        
        let postObservable = Observable.combineLatest(input.inputTitleString.orEmpty, input.inputPersonalColor.asObservable(), input.inputContentString.orEmpty, input.inputHashTags.orEmpty, photoString.asObserver())
            .map { title, personalColor, content, hashtags, images in
                print(title, content, personalColor.rawValue, hashtags, self.photoString)
                return PostQuery(product_id: "\(ProductId.baseProductId)\(personalColor.rawValue)", title: title, content: "\(content) \n\n\(hashtags)", content1: personalColor.rawValue, files: images)
            }
        
        
        input.inputEditButton
            .flatMap {
                // combineLastest대신 zip
                Observable.zip(input.inputTitleString.orEmpty, input.inputContentString.orEmpty, input.inputHashTags.orEmpty, input.inputPersonalColor.asObservable())
            }
            .debug()
            .subscribe(with: self) { owner, value in
                let title = value.0.trimmingCharacters(in: .whitespaces)
                let content = value.1.trimmingCharacters(in: .whitespaces)
                let hashtag = value.2.trimmingCharacters(in: .whitespaces)
                print("🤬\(value.3)")
                if title == "" || content == "" || hashtag == "" || value.3 == .none {
                    outputValid.accept((false, "수정"))
                } else {
                    outputValid.accept((true, "수정"))
                
                }
            }
            .disposed(by: disposeBag)
        
        input.inputUploadImagesTrigger
            .debug()
            .flatMap {
                if self.photos.isEmpty {
                    print("비어있음")
                    input.inputEditTrigger.onNext(())
                    return Observable<PostImageStingModel>.never()
                }
                print("image flatMap")
                var photoDatas: [Data]? = [] // Data타입으로 변경한 사진들(네트워크)
                for photo in self.photos {
                    photoDatas?.append(photo.changeToData())
                }

                return self.postManager.uploadPostImages(photoDatas)
                    .catch { error in
                        guard let error = error as? APIError else {
                            outputEditTrigger.onNext(nil)
                            return Observable<PostImageStingModel>.never()
                        }
                        if error == APIError.accessTokenExpired_419 {
                            TokenManager.shared.accessTokenAPI {
                                input.inputUploadImagesTrigger.onNext(())
                            } failureHandler: {
                                outputEditTrigger.onNext(nil)
                            } loginAgainHandler: {
                                self.outputLoginView.accept(())
                            }
                        }
                        outputEditTrigger.onNext(nil)
                        return Observable<PostImageStingModel>.never()
                    }
            }
            .subscribe(with: self) { owner, value in
                owner.photoString.onNext(value.files)
                print("사진 업로드성공 후 \(value.files)")
                input.inputEditTrigger.onNext(())
            }
            .disposed(by: disposeBag)
        
        input.inputEditTrigger
            .withLatestFrom(postObservable)
            .flatMap { postData in
                print(postData)
                print("업로드 네트워크")
                print("inputUploadTrigger network")
                guard let postId = self.postId else {
                    return Observable<PostModel>.never()
                }
                let query = PostQuery(title: postData.title, content: postData.content, content1: postData.content1, files: postData.files)
                return self.postManager.editPost(postId: postId, query: query)
                    .catch { error in
                        guard let error = error as? APIError else {
                            outputEditTrigger.onNext(nil)
                            return Observable<PostModel>.never()
                        }
                        if error == APIError.accessTokenExpired_419 {
                            TokenManager.shared.accessTokenAPI {
                                input.inputEditTrigger.onNext(())
                            } failureHandler: {
                                outputEditTrigger.onNext(nil)
                            } loginAgainHandler: {
                                print("다시 로그인해야돼용")
                                self.outputLoginView.accept(())
                            }
                        }
                        outputEditTrigger.onNext(nil)
                        return Observable<PostModel>.never()
                    }
            }
            .subscribe(with: self) { onwer, value in
                print("inputUploadTrigger subscribe")
                outputEditTrigger.onNext(value)
            }
            .disposed(by: disposeBag)
        
        // 갤러리 사진 선택 시 다시 그리기
        input.inputSelectPhotos
            .bind(with: self) { owner, _ in
                outputPhotoItems.accept(owner.photos)
            }
            .disposed(by: disposeBag)
        
        input.inputXbuttonTrigger
            .bind(with: self) { owner, tag in
                owner.photos.remove(at: tag)
                input.inputSelectPhotos.onNext(())
            }
            .disposed(by: disposeBag)
        
        return Output(outputValid: outputValid.asDriver(onErrorJustReturn: (false, "")), outputEditTrigger: outputEditTrigger, outputLoginView: outputLoginView, outputPhotoItems: outputPhotoItems.asDriver(onErrorJustReturn: []))
    }
}
