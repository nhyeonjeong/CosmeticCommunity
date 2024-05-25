# COCO 리드미

## 스크린샷

## 프로젝트 소개
> 화장품 후기를 올리며 인기있는 상품을 확인하고 중고화장품을 사고 팔 수 있는 커뮤니티 앱
- iOS, 서버 협업
    - iOS 1인 개발
- 개발 기간
    - 24.04.15 ~ 24.05.05 (약 3주)
- 개발 환경
    - 최소버전 16.0
    - 세로모드, 라이트모드만 지원
 
## 핵심기능
- 최근 인기많은 게시글추천 및 많이 쓰인 태그 추천
- 게시글 좋아요, 업로드, 수정, 삭제 / 댓글 작성, 삭제
- 좋아요한 게시글과 최근 본 게시글 확인
- 퍼스널컬러별로 검색기능
- 중고상품 결제 기능
- 사용자가 올린 게시글과 프로필 조회

## 사용한 기술스택
- UIKit, CodeBaseUI, MVVM
- RxSwift, RxCocoa, Alamofire, Snapkit, Kingfisher, Toast, Lottie, iamport
- Singleton, DI, UserDefault, Access Control, Router Pattern
- CompositionalLayout

## 기술설명
> MVVM InputOutput패턴
  - ViewController과 ViewModel을 분리하고 RxSwift, RxCocoa를 사용해 MVVM InputOutput패턴으로 작성
> Alamofire을 사용한 네트워크통신 NetworkManager Singleton패턴으로 구성
  - Alamofire 통신 후 Generic을 사용해 받아온 타입으로 Decoding
  - Decoding 결과는 RxSwift를 사용한 MVVM패턴을 위해 Observable로 반환
  - 통신 결과를 분기처리하여 실패 했다면 상태코드에 맞는 Error이벤트 전송
  - Router Pattern으로 헤더, 바디, 쿼리를 한번에 처리하여 urlRequest로 API통신
  - 게시글 / 좋아요 / 유저 / 결제를 담당하는 Manager에서 NetworkManager메서드에 접근
> KinfisherManager를 extension하여 헤더를 추가해 이미지경로로 서버에서 이미지를 가져오는 API통신
> UserDefault를 담당하는 클래스 Singleton 사용
> 엑세스토큰 만료시 대응할 일들을 TokenManager에 클로저로 전달
  - 리프레시 토큰만료시 로그인화면을 띄워주는 Observer에 이벤트 전달
> 외부에서 객체를 생성해 인스턴스 생성시 DI


## 트러블슈팅
