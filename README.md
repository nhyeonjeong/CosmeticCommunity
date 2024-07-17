# COCO 리드미

## 💄스크린샷

## 💄프로젝트 소개
> 화장품 후기를 올리며 인기있는 상품을 확인하고 중고화장품을 사고 팔 수 있는 커뮤니티 앱
- iOS, 서버 협업
    - iOS 1인 개발
- 개발 기간
    - 24.04.15 ~ 24.05.05 (약 3주)
- 개발 환경
    - 최소버전 16.0
    - 세로모드, 라이트모드만 지원
 
## 💄핵심기능
- 최근 인기많은 게시글추천 및 많이 쓰인 태그 추천
- 게시글 좋아요, 업로드, 수정, 삭제 / 댓글 작성, 삭제
- 좋아요한 게시글과 최근 본 게시글 확인
- 퍼스널컬러별로 검색기능
- 중고상품 결제 기능
- 사용자가 올린 게시글과 프로필 조회

## 💄사용한 기술스택
- UIKit, CodeBaseUI, MVVM
- RxSwift, RxCocoa, Alamofire, HTTP multipart/form-data, Snapkit, Kingfisher, Toast, Lottie, iamport
- Singleton, DI, UserDefault, Access Control, Router Pattern, ATS
- UICompositionalLayout, PHPickerViewControllerDelegate

## 💄기술설명
- MVVM InputOutput패턴
  - ViewController과 ViewModel을 분리하고 RxSwift, RxCocoa를 사용해 MVVM InputOutput패턴으로 작성
  - 이전에는 직접 Observable클래스로 직접 반응형코드를 구현했었는데 Operator를 사용해서 data stream을 쉽게 바꾸고 UI에 대한 반응도 더 쉽게 처리하기 위해 Rx 사용
  - InputOuput패턴을 사용으로 viewModel과 viewController사이의 데이터 흐름 이해도 증가
- Alamofire을 사용한 네트워크통신 NetworkManager Singleton패턴으로 구성
  - Generic을 사용해 Decodable한 타입들로 디코딩                                                
  - Decoding 결과는 RxSwift를 사용한 MVVM패턴을 위해 Observable로 반환
  - 네트워크 통신이 자주 쓰이기 때문에 싱글톤 패턴으로 구성
  - 통신 결과 statuscode를 분기처리하여 실패 했다면 그에 맞는 Error이벤트 전송
  - Router Pattern으로 헤더, 바디, 쿼리를 한번에 처리하여 urlRequest로 API통신
  - 게시글 / 좋아요 / 유저 / 결제를 담당하는 Manager에서 NetworkManager메서드에 접근
- KinfisherManager를 extension하여 헤더를 추가해 이미지경로로 서버에서 이미지를 가져오는 API통신
- 엑세스토큰 만료시 대응할 일들을 TokenManager에 클로저로 전달
  - 리프레시 토큰만료시 로그인화면을 띄워주는 Observer에 이벤트 전달
- 외부에서 객체를 생성해 코드의 재사용성과 유연성을 높이기 위해 인스턴스 생성시 DI
- Multipart통신으로 서버에 이미지를 포함한 데이터 업로드
- 커서기반 페이지네이션
- 네트워크 불안정시 새로고침 화면
- 여러 부분에서 사용되는 UI를 customView로 분리


## 💄트러블슈팅
### `1. loadObject클로저 구문으로 인해 사진이 추가되기 전 collectionview가 그려지는 문제`

1-1) 문제



사진첩에서 사진을 가져오기 위해 PHPickerViewControllerDelegate프로토콜 채택.
사진이 선택됐을 때 결과 results를 반복문을 돌면서 viewModel에 있는 appendPhotos메서드로 photos라는 [NSItemProviderReading]타입으로 저장.
반복문 내부에서 NSItemProvider를 UIImage로 변환하는 과정인 loadObject에서 클로저로 인해 비동기로 동작.
선택한 사진을 저장하는 것보다 선택한 사진 CollectionView뷰를 그려주는 inputSelectedPhotoItems.onNext가 먼저 실행되는 문제 발생.

1-2) 해결



DispatchQueue를 사용하여 for문을 돌면서 선택한 사진을 UIImage로 모두 변환 완료했을 때 선택된 사진 컬렉션뷰를 그리도록 변경
UIImage로 변경할 때마다 group.leave()를 실행, group.notify로 inputSelectedPhotoItems.onNext 실행
<details>
<summary>변경 후 코드</summary>
<div markdown="1">
<img width="533" alt="%EC%8A%A4%ED%81%AC%EB%A6%B0%EC%83%B7%202024-05-23%20%EC%98%A4%EC%A0%84%209 21 02" src="https://github.com/nhyeonjeong/CosmeticCommunity/assets/102401977/6c1f506e-2b8c-4179-a469-78485c4bcf57">
</div>
</details>

### `2. 커서 기반 페이지네이션으로 패치한 게시글 갯수 저장`
2-1) 문제


게시글 상세 확인 후 다시 뒤로 돌아가서 ColletionView를 보여줘야 할 때 이전에 패치했던 게시글의 수대로 보여주는게 아닌 다시 첫 페이지만을 보여주는 문제 발생

2-2) 해결



viewModel내부에서 패치할 게시글 수 변수인 limit 을 디폴트 20으로 생성
현재 뷰에서 보여주고 있는 게시글을 저장하고 있는 배열 postData생성
ViewController viewWillAppear메서드에서 화면이 보여지는 시점일때 limit을 변경후 API통신 하도록 함
이미 이전에 패치한 postData에 저장된 게시글수와 limit, 즉 20을 비교해서 더 큰 수를 limit에 적용
이후 패치를 했다면 limit을 다시 20으로 돌려놓는 과정으로 문제 해결
<details>
<summary>변경 후 ViewModel</summary>
<div markdown="1">
<img width="533" alt="%EC%8A%A4%ED%81%AC%EB%A6%B0%EC%83%B7%202024-05-23%20%EC%98%A4%EC%A0%84%209 21 02" src="https://github.com/nhyeonjeong/CosmeticCommunity/assets/102401977/9894f684-4af9-4879-8867-5f2c9d0fa8cd">
<img width="533" alt="%EC%8A%A4%ED%81%AC%EB%A6%B0%EC%83%B7%202024-05-23%20%EC%98%A4%EC%A0%84%209 21 02" src="https://github.com/nhyeonjeong/CosmeticCommunity/assets/102401977/072ec8e2-583c-4949-86eb-b2961b1749e9">
</div>
</details>
<details>
<summary>변경 후 ViewController</summary>
<div markdown="1">
<img width="533" alt="%EC%8A%A4%ED%81%AC%EB%A6%B0%EC%83%B7%202024-05-23%20%EC%98%A4%EC%A0%84%209 21 02" src="https://github.com/nhyeonjeong/CosmeticCommunity/assets/102401977/47769735-3749-45a1-8953-6af1be14803d">
</div>
</details>

### `3. 최근 본 게시물 이미 삭제된 게시글일 때 Observable.empty()처리`
3-1) 문제



최근 본 게시물의 postId를 유저디폴트에 저장하고 패치할때는 postId별로 API통신으로 결과를 가져오는 형태
하지만 삭제된 postId인 경우 에러를 캐치하는 과정에서 게시글을 그리는 과정을 통과해 아무것도 뜨지 않는 문제

3-2) 해결



최근 본 게시글을 가져와야 하는 API통신에서 에러가 발생했을 때 flatMap에 반환하는 형태를 Observable<PostModel>.never()로 하면  게시글을 그리는 이벤트를 전달하지 못하고 끝나버리게 되고 화면에는 아무것도 뜨지 않는다.

<details>
<summary>변경 후 코드</summary>
    Observable<PostModel>.empty()로 바꿔주면 postModelArray에 오류난 게시글은 저장하지 않을 뿐 끝까지 통신 실행 후 게시글을 그리는 이벤트를 뷰컨에 전달
<div markdown="1">
<img width="533" alt="%EC%8A%A4%ED%81%AC%EB%A6%B0%EC%83%B7%202024-05-23%20%EC%98%A4%EC%A0%84%209 21 02" src="https://github.com/nhyeonjeong/CosmeticCommunity/assets/102401977/7634859b-095b-4f60-9145-a89cc2c37968">
<img width="533" alt="%EC%8A%A4%ED%81%AC%EB%A6%B0%EC%83%B7%202024-05-23%20%EC%98%A4%EC%A0%84%209 21 02" src="https://github.com/nhyeonjeong/CosmeticCommunity/assets/102401977/e1fafa75-abe1-4907-805e-f197f7c42adb">
</div>
</details>

### `4. segment재사용성을 위한 제네릭과 프로토콜`
4-1) 고민


segment를 여러곳에서 재사용하기 위해서는 어떤 구조가 좋을까 고민

4-2) 해결


segment에 들어갈 메뉴 이름과 그 인덱스를 담을 프로토콜 생성
<details>
<summary>변경 후 코드</summary>
<div markdown="1">
<img width="545" alt="%EC%8A%A4%ED%81%AC%EB%A6%B0%EC%83%B7%202024-05-23%20%EC%98%A4%EC%A0%84%209 18 45" src="https://github.com/nhyeonjeong/CosmeticCommunity/assets/102401977/b88ab572-20ef-41e4-ac31-1bc5a0ccf378">
</div>
</details>

> 커스텀 SegmentControl으로 제네릭타입으로 SementCase프로토콜을 따르는 클래스를 전달
configureSement메서드에서 반복문을 돌리면서 메뉴 삽입
메뉴가 무엇이든, 몇 개든 제네릭으로 쉽게 처리
<details>
<summary>변경 후 코드</summary>
<div markdown="1">
<img width="533" alt="%EC%8A%A4%ED%81%AC%EB%A6%B0%EC%83%B7%202024-05-23%20%EC%98%A4%EC%A0%84%209 21 02" src="https://github.com/nhyeonjeong/CosmeticCommunity/assets/102401977/24128f30-8d45-4f95-81f9-db6eb67a1cb5">
<img width="563" alt="%EC%8A%A4%ED%81%AC%EB%A6%B0%EC%83%B7%202024-05-23%20%EC%98%A4%EC%A0%84%209 31 47" src="https://github.com/nhyeonjeong/CosmeticCommunity/assets/102401977/4e82d153-311a-44e4-aa91-a4f0be7b58a9">

</div>
</details>

> customSegment를 사용하려는 뷰에서 SegmentCase프로토콜을 따르는 Enum 생성
프로토콜으로서의 타입을 사용해서 segment객체 생성시 주입


## 💄기술회고
viewModel에서 API통신을 할 때마다 엑세스토큰이 만료될 때 발생하는 에러를 캐치하고 그때마다 엑세스토큰을 갱신하는 통신을 하였습니다. 
하지만 API통신함수를 호출하는 Manager에 이 부분을 작성해서 코드의 반복을 줄이고 Alamofire의 Interpretor을 사용해 엑세스토큰 갱신을 API통신 함수에서 하는 것이 더 나을 것 같다고 생각했습니다. 
또한 리프레시토큰이 만료되었을 때마다 viewModel에서 ViewController로 로그인 화면을 present하도록 신호를 보냈지만, notification center를 사용해 뷰모델에서 신호를 보내지 않고 내부적으로 처리했다면 모든 뷰모델에 반복적으로 같은 코드를 작성하지 않을 수 있을 것 같습니다.
네트워크 통신은 하나의 열거형으로 Router Pattern울 관리했고 URLRequest타입으로 통신하여 깔끔했지만, 통신종류에 따라서 열거형분리를 해줬다면 더 가독성 있는 코드가 될 것 같습니다.





